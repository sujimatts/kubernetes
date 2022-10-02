
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

### cluster.yml
This file is used for specifying the kubernetes cluster configurations. Use below command to generate it

```rke config --name cluster.yml``` 

[refer this](https://rancher.com/docs/rke/latest/en/installation/#creating-the-cluster-configuration-file) for more detials

### main.tf

Create ```main.tf``` file with [this](https://github.com/sujimatts/kubernetes/blob/main/rke_cluster_terraform/main.tf) content
  - ```required_providers``` - used to specify the rke provider and version
  - ```backend``` - defines where Terraform stores its state data files
  - ```local_sensitive_file``` - used to output the kubeconfig file to the specified location

You can now use terraform to deploy this kubernetes cluster using following commands
```
terraform init
terraform plan
terraform apply
```
kubectl cluster-info
![image](https://user-images.githubusercontent.com/40743779/193438094-15d0334b-550d-4be3-8b57-1fd4b88e3ccf.png)

use ```terraform destroy``` to destroy the cluster

## Create K8s deployment files
Refer [this](https://blog.knoldus.com/how-to-deploy-mysql-statefulset-in-kubernetes/) article to understand in detail. 
All the yml files used are uploaded [here](https://github.com/sujimatts/kubernetes/tree/main/rke_cluster_terraform/yaml_files)

You can install all these yml files by specifying the directory to kubectl. In this case ```kubectl apply -f yaml_files```

## Configure Jenkins
Now setup Jenkins and create a pipeline to deploy/destroy this via a single click.

1. Install Jenkins by referring this [article](https://www.digitalocean.com/community/tutorials/how-to-install-jenkins-on-ubuntu-22-04)
2. Install Kubernetes Plugin - https://plugins.jenkins.io/kubernetes/
                             - https://www.youtube.com/watch?v=fodA9rM5xoo
3. Create a Jenkins Credentials for connecting to Github repo
4. Setup ssh keys for jenkins user
5. Create a declarative [pipeline file](https://github.com/sujimatts/kubernetes/blob/main/rke_cluster_terraform/jenkins_files/jenkinsfile)
6. Add Chocie parameter to the pipeline job

## Run the pipeline to deploy
![image](https://user-images.githubusercontent.com/40743779/193438848-64f808a7-850e-494f-a554-7a9959149e00.png)
-----------------------------------------------------------------------------------------------------------------
![image](https://user-images.githubusercontent.com/40743779/193438830-a857e0d1-19b1-4d67-aeab-14ccc1d99502.png)
-----------------------------------------------------------------------------------------------------------------
### verify 
![image](https://user-images.githubusercontent.com/40743779/193438967-073035b7-0143-4182-85b3-f81bb4c79c8a.png)




