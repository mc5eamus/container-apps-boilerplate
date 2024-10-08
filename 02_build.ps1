#add parameter for prefix
param(
    [string]$template = "global"
)

$paramfile = $template + ".parameters.json"

Write-Host "Parameters from $paramfile"

# load prefix, project and salt from global.parameters.json
$parameters = Get-Content $paramfile | ConvertFrom-Json
$acrName = $parameters.parameters.acrName.value

$imageNameApi = $parameters.parameters.imageNameApi.value
$imageNameBackend = $parameters.parameters.imageNameBackend.value
$version = $parameters.parameters.imageVersion.value

Write-Host "Building images for version $version"

az acr login -n $acrName

$remoteImageNameApi = $acrName + ".azurecr.io/" + $imageNameApi
$remoteImageNameBackend = $acrName + ".azurecr.io/" + $imageNameBackend

#add version to image name if not latest
if ($version -ne "latest") {
    $remoteImageNameApi = $remoteImageNameApi + ":" + $version
    $remoteImageNameBackend = $remoteImageNameBackend + ":" + $version
}

Write-Host "Building $imageNameApi / $remoteImageNameApi"
docker build src/api -t $imageNameApi -t $remoteImageNameApi
Write-Host "Building $imageNameBackend / $remoteImageNameBackend"
docker build src/backend -t $imageNameBackend -t $remoteImageNameBackend

Write-Host "Pushing $remoteImageNameApi and $remoteImageNameBackend"
docker push $remoteImageNameApi
docker push $remoteImageNameBackend
