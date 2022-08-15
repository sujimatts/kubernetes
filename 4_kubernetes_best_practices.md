As the most popular container orchestration system, K8s is the de-facto standard for the modern cloud engineer to get to grips with. K8s is a notoriously complex system to use and maintain, so getting a good grasp of what you should and should not be doing, and knowing what is possible will get your deployment off to a solid start.

These recommendations cover common issues within 3 broad categories, application development, governance, and cluster configuration.

## Kubernetes Best Practices:

1.	[Use namespaces](#Use-namespaces)
2.	[Use readiness and liveness probes](#Use-readiness-and-liveness-probes)
3.	[Use resource requests and limits](#Use-resource-requests-and-limits)
4.	[Deploy your Pods as part of a Deployment, DaemonSet, ReplicaSet or StatefulSet across nodes.](#Deploy-your-Pods-as-part-of-a-Deployment-DaemonSet-ReplicaSet-or-StatefulSet-across-nodes)
5.	[Use multiple nodes](#Use-multiple-nodes)
6.	[Use Role-based access control (RBAC)](#Use-Role-based-access-control)
7.	[Host your Kubernetes cluster externally (use a cloud service)](#Host-your-Kubernetes-cluster-externally)
8.	[Upgrade your Kubernetes version](#Upgrade-your-Kubernetes-version)
9.	[Monitor your cluster resources and audit policy logs](#Monitor-your-cluster-resources-and-audit-policy-logs)
10.	[Use a version control system](#Use-a-version-control-system)
11.	[Use a Git-based workflow (GitOps)](#Use-a-Git-based-workflow)
12.	[Reduce the size of your containers](#Reduce-the-size-of-your-containers)
13.	[Organize your objects with labels](#Organize-your-objects-with-labels)
14.	[Use network policies](#Use-network-policies)
15.	[Use a firewall](#Use-a-firewall])

## Use Namespaces
Namespaces in K8s are important to utilize in order to organize your objects, create logical partitions within your cluster, and for security purposes. By default, there are 3 namespaces in a K8s cluster, ```default, kube-public and kube-system```.

RBAC can be used to control access to particular namespaces in order to limit the access of a group to control the blast-radius of any mistakes that might occur, for example, a group of developers may only have access to a namespace called ```dev``` , and have no access to the ```production``` namespace. The ability to limit different teams to different namespaces can be valuable to avoid duplicated work or resource conflict.

LimitRange objects can also be configured against namespaces to define the standard size for a container deployed in the namespace. ResourceQuotas can also be used to limit the total resource consumption of all containers inside a Namespace. Network policies can be used against namespaces to limit traffic between pods.

## Use Readiness and Liveness Probes
Readiness and Liveness probes are essentially types of health checks. These are another very important concept to utilize in K8s.

```Readiness probes``` ensure that requests to a pod are only directed to it when the pod is ready to serve requests. If it is not ready, then requests are directed elsewhere. It is important to define the readiness probe for each container, as there are no default values set for these in K8s. For example, if a pod takes 20 seconds to start and the readiness probe was missing, then any traffic directed to that pod during the startup time would cause a failure. Readiness probes should be independent and not take into account any dependencies on other services, such as a backend database or caching service.

```Liveness probes``` test if the application is running in order to mark it as healthy. For example, a particular path of a web app could be tested to ensure it is responding. If not, the pod will not be marked as healthy and the probe failure will cause the ```kubelet``` to launch a new pod, which will then be tested again. This type of probe is used as a recovery mechanism in case the process becomes unresponsive.

## Use Autoscaling
Where it is appropriate, autoscaling can be employed to dynamically adjust the number of pods (horizontal pod autoscaler), the amount of resources consumed by the pods (vertical autoscaler), or the number of nodes in the cluster (cluster autoscaler), depending on the demand for the resources.

The horizontal pod autoscaler can also scale a replication controller, replica set, or stateful set based on CPU demand.

Using scaling also brings some challenges, such as not storing persistent data in the container’s local filesystem, as this would prevent horizontal autoscaling. Instead, a PersistentVolume could be used.

The cluster autoscaler is useful when highly variable workloads exist on the cluster that may require different amounts of resources at different times based on demand. Removing unused nodes automatically is also a great way to save money!

## Use Resource Requests and Limits
Resource requests and limits (minimum and maximum amount of resources that can be used in a container) should be set to avoid a container starting without the required resources assigned, or the cluster running out of available resources.

Without limits, pods can utilize more resources than required, causing the total available resources to be reduced which may cause a problem with other applications on the cluster. Nodes may crash, and new pods may not be able to be placed corrected by the scheduler.

Without requests, if the application cannot be assigned enough resources, it may fail when attempting to start or perform erratically.

Resource requests and limits define the amount of CPU and Memory available in millicores and mebibytes. Note that if your process goes over the memory limit, the process is terminated, so it may not always be appropriate to set this in all cases. If your container goes over the CPU limit, the process is throttled.

## Deploy Your Pods as Part of a Deployment, DaemonSet, ReplicaSet, or StatefulSet Across Nodes.
A single pod should never be run individually. To improve fault tolerance, instead, they should always be part of a Deployment, DaemonSet, ReplicaSet or StatefulSet. The pods can then be deployed across nodes using anti-affinity rules in your deployments to avoid all pods being run on a single node, which may cause downtime if it was to go down.

## Use Multiple Nodes
Running K8s on a single node is not a good idea if you want to build in fault tolerance. Multiple nodes should be employed in your cluster so workloads can be spread between them.

## Use Role-based Access Control (RBAC)
Using RBAC in your K8s cluster is essential to properly secure your system. Users, Groups, and Service accounts can be assigned permissions to perform permitted actions on a particular namespace (a Role), or to the entire cluster (ClusterRole). Each role can have multiple permissions. To tie the defined roles to the users, groups, or service accounts, RoleBinding or ClusterRoleBinding objects are used.

RBAC roles should be set up to grant using the principle of least privilege, i.e. only permissions that are required are granted. For example, the admins group may have access to all resources, and your operators group may be able to deploy, but not be able to read secrets.

## Host Your Kubernetes Cluster Externally (Use a Cloud Service)
Hosting a K8s cluster on your own hardware can be a complex undertaking. Cloud services offer K8s clusters as platform as a service (PaaS), such as AKS (Azure Kubernetes Service) on Azure, or EKS (Amazon Elastic Kubernetes Service) on Amazon Web Services. Taking advantage of this means the underlying infrastructure will be managed by your cloud provider, and tasks around scaling your cluster, such as adding and removing nodes can be much more easily achieved, leaving your engineers to the management of what is running on the K8s cluster itself.

## Upgrade Your Kubernetes Version
As well as introducing new features, new K8s versions also include vulnerability and security fixes, which make it important to run an up-to-date version of K8s on your cluster. Support for older versions will likely not be as good as newer ones.

Migrating to a new version should be treated with caution however as certain features can be depreciated, as well as new ones added. Also, the apps running on your cluster should be checked that they are compatible with the newer targeted version before upgrading.

## Monitor Your Cluster Resources and Audit Policy Logs
Monitoring the components in the K8s control plane is important to keep resource consumption under control. The control plane is the core of K8s, these components keep the system running and so are vital to correct K8s operations. Kubernetes API, kubelet, etcd, controller-manager, kube-proxy and kube-dns make up the control plane.

Control plane components can output metrics in a format that can be used by Prometheus, the most common K8s monitoring tool.

Automated monitoring tools should be used rather than manually managing alerts.

Audit logging in K8s can be turned on whilst starting the kube-apiserver to enable deeper investigation using the tools of your choice. The audit.log will detail all requests made to the K8s API and should be inspected regularly for any issues that might be a problem on the cluster. The Kubernetes cluster default policies are defined in the audit-policy.yaml file and can be amended as required.

A log aggregation tool such as Azure Monitor can be used to send logs to a log analytics workspace from AKS for future interrogation using Kusto queries. On AWS Cloudwatch can be used. Third-party tools also provide deeper monitoring functionality such as Dynatrace and Datadog.

Finally, a defined retention period should be in place for the logs, around 30–45 days is common.

## Use a Version Control System
K8s configuration files should be controlled in a version control system (VCS). This enables a raft of benefits, including increased security, enabling an audit trail of changes, and will increase the stability of the cluster. Approval gates should be put in place for any changes made so the team can peer-review the changes before they are committed to the main branch.

Use a Git-based Workflow (GitOps)
Successful deployments of K8s require thought on the workflow processes used by your team. Using a git-based workflow enables automation through the use of CI/CD (Continuous Integration / Continuous Delivery) pipelines, which will increase application deployment efficiency and speed. CI/CD will also provide an audit trail of deployments. Git should be the single source of truth for all automation and will enable unified management of the K8s cluster. You can also consider using a dedicated infrastructure delivery platform such as Spacelift, which recently introduced Kubernetes support.

## Reduce the Size of Your Containers
Smaller image sizes will help speed up your builds and deployments and reduce the amount of resources the containers consumed on your K8s cluster. Uneccesery packages should be removed where possible, and small OS distribution images such as Alpine should be favored. Smaller images can be pulled faster than larger images, and consume less storage space.

Following this approach will also provide security benefits as there will be fewer potential vectors of attack for malicious actors.

## Organize Your Objects with Labels
K8s labels are key-value pairs that are attached to objects in order to organize your cluster resources. Labels should be meaningful metadata that provide a mechanism to track how different components in the K8s system interact.

Recommended labels for pods in the official K8s documentation include name, instance, version, component, part-of, and managed-by.

Labels can also be used in a similar way to using tags in a cloud environment on resources in order to track things related to the business, such as object ownership, and the environmentan object should belong to.

Also recommended is to use labels to detail security requirements, including confidentiality and compliance.

## Use Network Policies
Network policies should be employed to restrict traffic between objects in the K8s cluster. By default, all containers can talk to each other in the network, something that presents a security risk if malicious actors gain access to a container, allowing them to traverse objects in the cluster. Network policies can control traffic at the IP and port level, similar to the concept of security groups in cloud platforms to restrict access to resources. Typically, all traffic should be denied by default, then allow rules should be put in place to allow required traffic.

## Use a Firewall
As well as using network policies to restrict internal traffic on your K8s cluster, you should also put a firewall in front of your K8s cluster in order to restrict requests to the API server from the outside world. IP addresses should be whitelisted and open ports restricted.

## Key Points
Following the best practices listed in this article when designing, running, and maintaining your Kubernetes cluster will put you on the path to success on your modern application journey!
