# infra-pipeline
This will set up the infrastructure for the trusted pipeline.


## The repository structure
This repository has the following directories :

- Components
- Environments

The components directory contains grouped resources that are frequently used and the environemnts directory specifies the different environment that will use these resources.


## Sandbox commands

```bash
AWS_REGION=eu-west-2 AWS_PROFILE=tintulip-sandbox-admin ENV=sandbox make plan
AWS_REGION=eu-west-2 AWS_PROFILE=tintulip-sandbox-admin ENV=sandbox make apply
```