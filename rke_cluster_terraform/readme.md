
## Pre-Requsites
1. Install terraform - https://www.terraform.io/downloads 
  (Version used --> Terraform v1.3.1)
2. Install Kubectl - https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
   (Version used --> v1.22.1)
3. Install docker - https://docs.docker.com/engine/install/ubuntu/
   (Version used --> 20.10.18,)
   
## Create Kubernetes Cluster

We are using [Rancher](https://www.rancher.com/products/rancher) for setting up the k8s cluster. [Rancher](https://www.rancher.com/products/rancher) is an open source software platform that enables organizations to run containers in production. 

We are using Terraform inbuilt provider called [RKE](https://registry.terraform.io/providers/rancher/rke/latest/docs) to interact with Rancher Kubernetes Engine kubernetes clusters.
