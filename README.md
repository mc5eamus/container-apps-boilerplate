# container-apps-boilerplate

## naming template

* *project* - human readable name of deployment (e.g. *callcenter*)
* *environmet* - commonly dev / prepro / prod (e.g. *dev*)
* *salt* - an additional differentiator such as a number to keep the naming unique (e.g. *01*)

All resources created automatically will follow the schema project-environment-salt (e.g. callcenter-dev-01) as far as dashes are allowed, otherwise they will be omitted.

## deployment

Deployment templates creates a new resource group in the subscription your az context defaults to.
Prior to deployment, make sure to adjust the values in *global.parameters.json*. You can also create a copy of the parameter file and provide it as a parameter.

### Infrastructure
<pre>az deployment sub create --location *your-location* --name <strong>your-infra-deployment-name</strong> --template-file 01_infra.bicep --parameters @global.parameters.json </pre>

For subsequent deployments location could be omitted.

### Building Images
<pre> powershell -file 02_build.ps1 </pre> 
If you are using a different parameter file, make sure to use the *-template*</pre> parameter to refer to *template.parameters.json* as input.
<pre> powershell -file 02_build.ps1 -template local</pre>

### Deploying apps
<pre> az deployment sub create --name <strong>your-app-deployment-name</strong> --template-file 03_app.bicep --parameters @global.parameters.json </pre> 

