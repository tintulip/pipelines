# artifactory
Contains infrastructure as code to configure artifactory.

This stack is for a temporary artifactory instance as we refactor the original one, and meant to be reflected on the `artifactory` stack.

## Authenticating to arti

Have the `ARTIFACTORY_API_KEY` environment variable populated, the provider will pick it up as per [provider documentation](https://registry.terraform.io/providers/jfrog/artifactory/latest/docs#api_key)