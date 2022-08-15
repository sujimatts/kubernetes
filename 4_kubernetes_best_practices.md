As the most popular container orchestration system, K8s is the de-facto standard for the modern cloud engineer to get to grips with. K8s is a notoriously complex system to use and maintain, so getting a good grasp of what you should and should not be doing, and knowing what is possible will get your deployment off to a solid start.

These recommendations cover common issues within 3 broad categories, application development, governance, and cluster configuration.

## Kubernetes Best Practices:

1.	[Use namespaces](#Use-namespaces)
2.	Use readiness and liveness probes
3.	Use resource requests and limits
4.	Deploy your Pods as part of a Deployment, DaemonSet, ReplicaSet or StatefulSet across nodes.
5.	Use multiple nodes
6.	Use Role-based access control (RBAC)
7.	Host your Kubernetes cluster externally (use a cloud service)
8.	Upgrade your Kubernetes version
9.	Monitor your cluster resources and audit policy logs
10.	Use a version control system
11.	Use a Git-based workflow (GitOps)
12.	Reduce the size of your containers
13.	Organize your objects with labels
14.	Use network policies
15.	Use a firewall

Use Namespaces
Namespaces in K8s are important to utilize in order to organize your objects, create logical partitions within your cluster, and for security purposes. By default, there are 3 namespaces in a K8s cluster, ```default, kube-public and kube-system```.

RBAC can be used to control access to particular namespaces in order to limit the access of a group to control the blast-radius of any mistakes that might occur, for example, a group of developers may only have access to a namespace called ```dev``` , and have no access to the ```production``` namespace. The ability to limit different teams to different namespaces can be valuable to avoid duplicated work or resource conflict.

LimitRange objects can also be configured against namespaces to define the standard size for a container deployed in the namespace. ResourceQuotas can also be used to limit the total resource consumption of all containers inside a Namespace. Network policies can be used against namespaces to limit traffic between pods.

Use Readiness and
