# SimpleTimeService
A simple microservice which will be dockerized and deployed to AKS cluster

Docker hub image: [docker.io/ritika54/simple_time_service:latest][def]

[def]: https://hub.docker.com/repository/docker/ritika54/simple_time_service/general

## How to Run the application?

Just pull above mentioned image

`docker pull docker.io/ritika54/simple_time_service:latest`

then run the container:

`docker run -p host_port:8081 docker.io/ritika54/simple_time_service:latest`

Then you can check the application running on 
`http://localhost:host_port`

## How I am running Terraform?
With HCP Terraform Cloud

## How to run Terraform on local?
Login to your azure account, if you want to deploy the resources
* `az login`
* Set environment variables (Below commands are for poweshell)
    ```
    $env:ARM_SUBSCRIPTION_ID="your-subscription-id"
    $env:ARM_CLIENT_ID="your-client-id"
    $env:ARM_CLIENT_SECRET="your-client-secret"
    $env:ARM_TENANT_ID="your-tenant-id"
    ```
* `cd gitops/terraform`
* `terraform init`
* `terraform plan`
* `terraform apply`

## How to deploy the application on AKS cluster?
Yaml file are located at `gitops/chart`

* `az login`
* `az account set --subscription SUBSCRIPTION_ID`
* `az aks get-credentials --resource-group RESOURCEGROUPT_NAME --name AKS_CLUSTER_NAME --overwrite-existing`
* Remove the secret yaml as you will be using the public image of docker hub. For my case I deployed image from my GitHub container registry, so in-order to pull it I added ImagePullSecret.
* `kubectl apply -f /gitops/chart/namespace.yaml`
* `kubectl apply -f /gitops/chart`
* These yaml will create a namespace named `simple-time-service` and deploy the resources there.