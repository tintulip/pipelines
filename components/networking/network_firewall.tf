data "aws_nat_gateway" "nat" {
  vpc_id = module.internet_vpc.vpc_id
}

data "aws_subnet" "nat_subnet" {
  id = data.aws_nat_gateway.nat.subnet_id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = module.internet_vpc.vpc_id
  tags = {
    Name        = "builder-pipeline"
    Owner       = "Governance"
    Environment = "builder"
  }
}

locals {
  cidr_blocks = { "eu-west-2a" = "10.100.20.0/24" }
  endpoint_id = flatten(aws_networkfirewall_firewall.network_firewall.firewall_status[0].sync_states[*].attachment[*].endpoint_id)
}

resource "aws_subnet" "firewall_subnet" {
  for_each          = local.cidr_blocks
  vpc_id            = module.internet_vpc.vpc_id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "builder-pipeline-firewall-${each.key}"
  }
}

resource "aws_route" "firewall_to_internet" {
  route_table_id         = aws_route_table.builder_firewall.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "builder_firewall" {
  vpc_id = module.internet_vpc.vpc_id

  tags = {
    Name = "builder-pipeline-firewall"
  }
}

resource "aws_route_table_association" "builder_firewall" {
  for_each       = aws_subnet.firewall_subnet
  subnet_id      = each.value["id"]
  route_table_id = aws_route_table.builder_firewall.id
}

resource "aws_route_table" "igw" {
  vpc_id = module.internet_vpc.vpc_id

  route {
    cidr_block      = data.aws_subnet.nat_subnet.cidr_block
    vpc_endpoint_id = one(local.endpoint_id)
  }

  tags = {
    Name = "builder-pipeline-igw"
  }
}

resource "aws_route_table_association" "igw" {
  route_table_id = aws_route_table.igw.id
  gateway_id     = aws_internet_gateway.igw.id
}

resource "aws_networkfirewall_firewall_policy" "firewall_policy" {
  name = "firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.allowed_domains.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.drop_non_http_traffic.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_domains.arn
    }
  }
}

resource "aws_networkfirewall_rule_group" "drop_non_http_traffic" {
  capacity = 100
  name     = "drop-non-http-traffic"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [module.internet_vpc.cidr_block]
        }
      }
    }
    rules_source {
      rules_string = <<EOF
      drop tcp $HOME_NET any -> $EXTERNAL_NET any (msg:"Blocked TCP that is not HTTP"; flow:established; app-layer-protocol:!http; sid:100; rev:1;)
      drop ip $HOME_NET any -> $EXTERNAL_NET any (msg: "Block non-TCP traffic."; ip_proto:!TCP;sid:200; rev:1;)
      EOF
    }
  }
}

resource "aws_networkfirewall_rule_group" "block_domains" {
  capacity = 100
  name     = "block-domains"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [module.internet_vpc.cidr_block]
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets = [
          ".gist.github.com",
          "gist.githubusercontent.com"
        ]
      }
    }
  }
}


resource "aws_networkfirewall_rule_group" "allowed_domains" {
  capacity = 100
  name     = "allowed-domains"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [module.internet_vpc.cidr_block]
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets = [
          ".amazonaws.com",
          "github.com",
          "github-releases.githubusercontent.com",
          "raw.githubusercontent.com",
          "semgrep.dev",
          ".hashicorp.com",
          "registry.terraform.io",
          ".tintulip.jfrog.io",
          ".toolbox-data.anchore.io",
        ]
      }
    }
  }
}

resource "aws_networkfirewall_firewall" "network_firewall" {
  name                = "network-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.firewall_policy.arn
  vpc_id              = module.internet_vpc.vpc_id

  dynamic "subnet_mapping" {
    for_each = aws_subnet.firewall_subnet
    content {
      subnet_id = subnet_mapping.value["id"]
    }
  }
}
