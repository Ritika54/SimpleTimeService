# SimpleTimeService
SimpleTimeService is a lightweight microservice that exposes a single HTTP endpoint and returns the current timestamp along with the visitor’s IP address in JSON format.

This repository contains:
* Application source code
* Dockerfile
* Terraform code to deploy the service on Azure
* Deployment documentation

## Tech Stack
* Language: Go
* Containerization: Docker
* Cloud Provider: Microsoft Azure
* Infrastructure: Terraform
* Orchestration: Azure Kubernetes Service


## Repository Structure
```
.
├── .github/
|   ├── workflows/
│       ├── cicd.yml
|   ├── CODEOWNERS
├── simple_time_service/
│   ├── main.go
├── Dockerfile
├── gitops/
|   ├── terraform/
│       ├── main.tf
│       ├── variables.tf
│       ├── network.tf
│       └── providers.tf
|   ├── kubernetes_manifests/
│       ├── deployment.yaml
│       ├── namespace.yaml
│       ├── secret.yaml
│       └── service.yaml
├── .gitignore
└── README.md
```


## How to Run the application?

Docker hub image: [docker.io/ritika54/simple_time_service:latest][def]

[def]: https://hub.docker.com/repository/docker/ritika54/simple_time_service/general

Just pull above mentioned image

`docker pull docker.io/ritika54/simple_time_service:latest`

then run the container (Replace `host_port` with any available port on your machine.):

`docker run -p host_port:8081 docker.io/ritika54/simple_time_service:latest`

Then you can check the application running on 
`http://localhost:host_port`

## Terraform provisions:
* Azure VNet with public and private subnets
* AKS cluster deployed in private subnets
* Public IP to expose the k8s service as Loadbalancer

## How Terraform is managed on this repository?
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

## How to deploy the application on AKS cluster from local?
YAML files are located at `gitops/kubernetes_manifests`

* `az login`
* `az account set --subscription SUBSCRIPTION_ID`
* `az aks get-credentials --resource-group RESOURCEGROUPT_NAME --name AKS_CLUSTER_NAME --overwrite-existing`
* update [image](https://github.com/Ritika54/SimpleTimeService/blob/main/gitops/kubernetes_manifests/deployment.yaml#L17) with docker hub image
* Remove the secret yaml as you will be using the public image of docker hub. For my case I deployed image from my GitHub container registry, so in order to pull it I added ImagePullSecret.
* `kubectl apply -f /gitops/kubernetes_manifests/namespace.yaml`
* `kubectl apply -f /gitops/kubernetes_manifests`
* These yaml will create a namespace named `simple-time-service` and deploy the resources there.