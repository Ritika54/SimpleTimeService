# Troubleshooting & Errors Faced

This document lists the major errors encountered while building and deploying **SimpleTimeService**, along with their root causes and resolutions.

---

### 1. Container Fails to Start – Non-Root User Error

>Error: failed to create containerd container: mount callback failed on
/var/lib/containerd/tmpmounts/containerd-mount1838393416: no users found

**ROOT CAUSE**: The Docker image was configured to run as a non-root user, but the user was not created in the image.

**SOLUTION**: Created a dedicated user inside the Dockerfile and switched to it before starting the application.

---
### 2. Image Pull Failure from GitHub Container Registry

> reason: Failed \
message: >- \
  Failed to pull image "ghcr.io/ritika54/simple_time_service:latest": failed to
  pull and unpack image "ghcr.io/ritika54/simple_time_service:latest": failed to
  resolve reference "ghcr.io/ritika54/simple_time_service:latest": failed to
  authorize: failed to fetch anonymous token: unexpected status from GET request
  to
  https://ghcr.io/token?scope=repository%3Aritika54%2Fsimple_time_service%3Apull&service=ghcr.io:
  401 Unauthorized

**ROOT CAUSE**: The GitHub Container Registry token did not have sufficient permissions, and the image was not accessible anonymously.

**SOLUTION**:
- Removed and redeployed the image
- Ensured the token had proper access

---
### 3. Pod Continuously restarts with `OOMKilled`
> OOMKilled

**ROOT CAUSE**: The container exceeded its allocated memory limit.

**SOLUTION**: Increased resource limits in the Kubernetes deployment configuration.

---
### 4. `kubectl port-forward` Connection Refused

> $ kubectl port-forward svc/simple-time-service 8085:8080 -n simple-time-service \
Forwarding from 127.0.0.1:8085 -> 8080 \
Forwarding from [::1]:8085 -> 8080 \
Handling connection for 8085 \
Handling connection for 8085 \
E1211 19:44:15.267065   26760 portforward.go:406] an error occurred forwarding 8085 -> 8080: error forwarding port 8080 to pod 25bf05d0b8eca329480ee4b5fb5e576a822fa377efdbcd721d356ebb4ba14f4e, uid : failed to execute portforward in network namespace "/var/run/netns/cni-2f805913-b580-7f62-696e-50219023927c": failed to connect to localhost:8080 inside namespace "25bf05d0b8eca329480ee4b5fb5e576a822fa377efdbcd721d356ebb4ba14f4e", IPv4: dial tcp4 127.0.0.1:8080: connect: connection refused IPv6 dial tcp6: address localhost: no suitable address found \
E1211 19:44:15.268633   26760 portforward.go:406] an error occurred forwarding 8085 -> 8080: error forwarding port 8080 to pod 25bf05d0b8eca329480ee4b5fb5e576a822fa377efdbcd721d356ebb4ba14f4e, uid : failed to execute portforward in network namespace "/var/run/netns/cni-2f805913-b580-7f62-696e-50219023927c": failed to connect to localhost:8080 inside namespace "25bf05d0b8eca329480ee4b5fb5e576a822fa377efdbcd721d356ebb4ba14f4e", IPv4: dial tcp4 127.0.0.1:8080: connect: connection refused IPv6 dial tcp6: address localhost: no suitable address found \
E1211 19:44:15.274468   26760 portforward.go:234] lost connection to pod

**ROOT CAUSE**: Port mismatch between:
- Application listening port
- Container port
- Service port
- Port-forward command

**SOLUTION**: Aligned ports across:
- Application
- Dockerfile
- Kubernetes Deployment
- Kubernetes Service

After correcting the port configuration, port-forwarding worked successfully.

---
### 5. Load Balancer Creation Failure (Authorization)

> reason: SyncLoadBalancerFailed \
message: > \
  Error syncing load balancer: failed to ensure load balancer:
  findMatchedPIPByLoadBalancerIP: failed to listPIP: GET
  http://localhost:7788/subscriptions/492ab093-d627-4955-b6ba-0306b9a8b13e/resourceGroups/rg-ritika-test/providers/Microsoft.Network/publicIPAddresses  
RESPONSE 403: 403 Forbidden \
ERROR CODE: AuthorizationFailed \
  { \
    "error": { \
      "code": "AuthorizationFailed", \
      "message": "The client '04102943-e6a1-4475-8932-566b20c29f20' with object id '9379cb34-36f6-4ea9-b178-7457f03f4020' does not have authorization to perform action 'Microsoft.Network/publicIPAddresses/read' over scope '/subscriptions/492ab093-d627-4955-b6ba-0306b9a8b13e/resourceGroups/rg-ritika-test/providers/Microsoft.Network' or the scope is invalid. If access was recently granted, please refresh your credentials." \
    } \
  }

**ROOT CAUSE**: The Service Principal used by AKS did not have sufficient permissions to read public IP resources under resource group.

**SOLUTION**: 
1. Assigned the Service Principal with `Reader` and `Network Contributor` roles on the primary resource group
2. Recreated the Kubernetes Service

Load Balancer was successfully provisioned afterward.

---
### 6. AKS Cluster Creation Failed – Service CIDR Overlap

> Error: creating Kubernetes Cluster (Subscription: "492ab093-d627-4955-b6ba-0306b9a8b13e" Resource Group Name: "rg-ritika-test" Kubernetes Cluster Name: "aks-ritika-test"): performing CreateOrUpdate: unexpected status 400 (400 Bad Request) with response: { "code": "ServiceCidrOverlapExistingSubnetsCidr", "details": null, "message": "The specified service CIDR 10.0.0.0/16 is conflicted with an existing subnet CIDR 10.0.3.0/24. Please see https://aka.ms/aks/servicecidroverlap for how to fix the error.", "subcode": "", "target": "networkProfile.serviceCIDR" } \
with azurerm_kubernetes_cluster.aks_cluster \
on main.tf line 6, in resource "azurerm_kubernetes_cluster" "aks_cluster": \
`resource "azurerm_kubernetes_cluster" "aks_cluster" {`

**ROOT CAUSE**: The Kubernetes **service CIDR** overlapped with the VNet subnet IP range.

This happened because:
- The `service_cidr` was **not explicitly defined** in the AKS Terraform configuration
- Terraform (Azure provider) therefore used the **default service CIDR: `10.0.0.0/16`**
- The same `10.0.0.0` address space was already being used for VNet subnets

AKS requires the following CIDR ranges to be **non-overlapping**:
- VNet subnet CIDRs
- Kubernetes service CIDR
- Kubernetes pod CIDR 

**SOLUTION**: 
Updated the VNet subnet IP ranges from:
`10.0.0.0/16` to `10.1.0.0/16`.
This removed the overlap with the default AKS service CIDR and allowed the cluster to be created successfully.

AKS cluster creation succeeded after correcting the network ranges.

**BETTER SOLUTION**
Always explicitly define the following in AKS Terraform configurations:
- `service_cidr`
- `dns_service_ip`
- `pod_cidr`

This avoids unintended overlaps caused by provider defaults.

---
### 7. Virtual Network Update Failed – Subnet CIDR Outside VNet Range
> Error: updating Virtual Network (Subscription: "492ab093-d627-4955-b6ba-0306b9a8b13e" Resource Group Name: "rg-ritika-test" Virtual Network Name: "vnet-aks-hybrid"): performing CreateOrUpdate: unexpected status 400 (400 Bad Request) with error: NetcfgSubnetRangeOutsideVnet: Subnet 'subnet-private-1' is not valid because its IP address range is outside the IP address range of virtual network 'vnet-aks-hybrid'. \
with azurerm_virtual_network.vnet \
on network.tf line 1, in resource "azurerm_virtual_network" "vnet": \
`resource "azurerm_virtual_network" "vnet" {`

**ROOT CAUSE**:
The subnet CIDR ranges no longer matched the updated VNet address space.

This occurred after modifying the VNet CIDR (from `10.0.0.0/16` to `10.1.0.0/16`)
to resolve the AKS service CIDR overlap issue, while one or more subnets were
still defined using the old IP ranges.

_Azure does not allow updating a VNet address space, while existing subnets fall outside the new VNet CIDR_

**SOLUTION**
- Manually deleted the existing Virtual Network
- Re-ran Terraform to recreate the VNet and subnets with consistent CIDR ranges