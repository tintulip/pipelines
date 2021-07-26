module "state_bucket" {
  source      = "../../components/remote-state-bucket"
  bucket_name = var.stack_id
}