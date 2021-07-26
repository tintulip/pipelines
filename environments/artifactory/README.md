# artifactory
Contains infrastructure as code to configure artifactory.

This stack is for a temporary artifactory instance as we refactor the original one, and meant to be reflected on the `artifactory` stack.

## Authenticating to arti

Have the `ARTIFACTORY_API_KEY` environment variable populated, the provider will pick it up as per [provider documentation](https://registry.terraform.io/providers/jfrog/artifactory/latest/docs#api_key)

## Authenticating to GH

Have the `GITHUB_TOKEN` environment variable populated, the provider will pick it up as per [provider documentation](https://registry.terraform.io/providers/integrations/github/latest/docs#oauth--personal-access-token)

This stack needs to authenticate to GH to make a CI-read Artifactory credential to the GH organisation, this currently requires the `admin:org` scope being enabled for your Personal Access Token as per [GH API documentation](https://docs.github.com/en/rest/reference/actions#secrets),  (last accessed Jul 2021).