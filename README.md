# container-apps-boilerplate

## naming template

* *project* - human readable name of deployment (e.g. *callcenter*)
* *environmet* - commonly dev / prepro / prod (e.g. *dev*)
* *salt* - an additional differentiator such as a number to keep the naming unique (e.g. *01*)

All resources created automatically will follow the schema project-environment-salt (e.g. callcenter-dev-01) as far as dashes are allowed, otherwise they will be omitted.

## deployment

Deployment templates creates a new resource group in the subscription your az context defaults to.

<pre> az deployment sub create --name *your-deployment-name* --template-file 01_infra.bicep --parameters @global.parameters.json </pre>
