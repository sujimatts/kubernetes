# Securing Kubernetes Cluster using Kubescape and kube-bench
## What is kube-bench?
kube-bench is a tool from Aqua Security. It is an open source offering that analyzes the cluster against Centre for Internet Security guidelines.

## How does kube-bench work?
kube-bench is a tool that doesn’t run continuously on your cluster. Rather, one can run it on all the nodes using simple commands. The test is divided in different sections, such as:

  -  Master Node Security Configuration
  -  etcd Node Configuration
  -  Control Plane Configuration
  -  Worker Node Security Configuration
  -  Kubernetes Policies
  -  
Every section publishes its own tests, remediations for the tests that are failing or in warning, and its summary (count of PASS/FAIL/WARN/INFO checks). At the end, an overall summary is published. Following are some small snippets of output of the kube-bench scan on a minikube cluster:

Checks Example
```
[INFO] 1 Master Node Security Configuration
[INFO] 1.1 Master Node Configuration Files
[FAIL] 1.1.1 Ensure that the API server pod specification file permissions are set to 644 or more restrictive (Automated)
[FAIL] 1.1.2 Ensure that the API server pod specification file ownership is set to root:root (Automated)
[FAIL] 1.1.3 Ensure that the controller manager pod specification file permissions are set to 644 or more restrictive (Automated)
[FAIL] 1.1.4 Ensure that the controller manager pod specification file ownership is set to root:root (Automated)
[FAIL] 1.1.5 Ensure that the scheduler pod specification file permissions are set to 644 or more restrictive (Automated)
```
```
[INFO] 1.2 API Server
[WARN] 1.2.1 Ensure that the --anonymous-auth argument is set to false (Manual)
[PASS] 1.2.2 Ensure that the --token-auth-file parameter is not set (Automated)
[PASS] 1.2.3 Ensure that the --kubelet-https argument is set to true (Automated)
[PASS] 1.2.4 Ensure that the --kubelet-client-certificate and --kubelet-client-key arguments are set as appropriate (Automated)
[FAIL] 1.2.5 Ensure that the --kubelet-certificate-authority argument is set as appropriate (Automated)
```

## Remediations Example
```
1.1.1 Run the below command (based on the file location on your system) on the
master node.
For example, chmod 644 /etc/kubernetes/manifests/kube-apiserver.yaml

1.1.2 Run the below command (based on the file location on your system) on the master node.
For example,
chown root:root /etc/kubernetes/manifests/kube-apiserver.yaml

1.1.3 Run the below command (based on the file location on your system) on the master node.
For example,
chmod 644 /etc/kubernetes/manifests/kube-controller-manager.yaml

1.1.4 Run the below command (based on the file location on your system) on the master node.
For example,
chown root:root /etc/kubernetes/manifests/kube-controller-manager.yaml

1.1.5 Run the below command (based on the file location on your system) on the master node.
For example,
chmod 644 /etc/kubernetes/manifests/kube-scheduler.yaml
```
```
1.2.1 Edit the API server pod specification file /etc/kubernetes/manifests/kube-apiserver.yaml
on the master node and set the below parameter.
--anonymous-auth=false

1.2.5 Follow the Kubernetes documentation and setup the TLS connection between
the apiserver and kubelets. Then, edit the API server pod specification file
/etc/kubernetes/manifests/kube-apiserver.yaml on the master node and set the
--kubelet-certificate-authority parameter to the path to the cert file for the certificate authority.
--kubelet-certificate-authority=<ca-string>
```

## Summary Example
```
24 checks PASS
27 checks FAIL
13 checks WARN
0 checks INFO
```
## Deployment methods
kube-bench can be executed as a simple command on the host, as a container on the host using Docker command, or as a job inside Kubernetes Cluster. In case it is run inside a container/pod, it will need access to the PID namespace of the host system. The methods to run kube-bench in AKS, EKS, GKE, On-prem cluster, Openshift and ACK (Alibaba Cloud Container Service For Kubernetes) are different but well documented.

## When to use kube-bench?
kube-bench’s analysis is great when it scans nodes (master node, worker node, etcd node). It gives very precise instructions regarding ownership and permissions for configuration files as well as for flags and arguments that are wrongly configured. It also gives commands directly wherever applicable. However, we experienced that the outputs were more of guidelines when it came to scanning artifacts inside the cluster. There was no specific information about which artifact had misconfiguration. Following are some of the examples of checks and remediation under the Kubernetes Policies section:

Checks
```
[INFO] 5 Kubernetes Policies
[INFO] 5.1 RBAC and Service Accounts
[WARN] 5.1.1 Ensure that the cluster-admin role is only used where required (Manual)
[WARN] 5.1.2 Minimize access to secrets (Manual)
[WARN] 5.1.3 Minimize wildcard use in Roles and ClusterRoles (Manual)
```
```
[INFO] 5.2 Pod Security Policies
[WARN] 5.2.1 Minimize the admission of privileged containers (Automated)
[WARN] 5.2.2 Minimize the admission of containers wishing to share the host process ID namespace (Automated)
[WARN] 5.2.3 Minimize the admission of containers wishing to share the host IPC namespace (Automated)
[WARN] 5.2.4 Minimize the admission of containers wishing to share the host network namespace (Automated)
[WARN] 5.2.5 Minimize the admission of containers with allowPrivilegeEscalation (Automated)
```

Remediations
```
5.1.1 Identify all clusterrolebindings to the cluster-admin role. Check if they are used and if they need this role or if they could use a role with fewer privileges.
Where possible, first bind users to a lower privileged role and then remove the clusterrolebinding to the cluster-admin role :
kubectl delete clusterrolebinding [name]

5.1.2 Where possible, remove get, list and watch access to secret objects in the cluster.

5.1.3 Where possible replace any use of wildcards in clusterroles and roles with specific objects or actions.
```
```
5.2.1 Create a PSP as described in the Kubernetes documentation, ensuring that the .spec.privileged field is omitted or set to false.

5.2.2 Create a PSP as described in the Kubernetes documentation, ensuring that the .spec.hostPID field is omitted or set to false.

5.2.3 Create a PSP as described in the Kubernetes documentation, ensuring that the .spec.hostIPC field is omitted or set to false.

5.2.4 Create a PSP as described in the Kubernetes documentation, ensuring that the .spec.hostNetwork field is omitted or set to false.

5.2.5 Create a PSP as described in the Kubernetes documentation, ensuring that the .spec.allowPrivilegeEscalation field is omitted or set to false.
```

Such outputs don’t give a clear picture about the cluster. For instance, the above output does not provide any information about the specific fields/clusterrolebindings which violate the security controls. And if your cluster is large, then this kind of information does not help much.

## Integrations with other tools
At the time of writing this blog, kube-bench does not offer any native integration with other tools. However, AWS Security Hub has added it as an open source tool integration. Here are more details on kube-bench integrations with other tools. Apart from this, kube-bench also provides an output of the scan in JSON format, so that if you want to make reports or create alerts on the basis of cluster scan results, you can create a script around it.

So, this was all about kube-bench. As we saw above, it is great when we want to secure the cluster from the nodes’ end. However, it does not provide pinpoint information when it comes to checking vulnerabilities in Kubernetes artifacts’ configurations. These can be very well covered using the other tool that we are about to discuss and has grown popular recently, called Kubescape.

# What is Kubescape?
Kubescape is a tool from ARMO Security. Its open source offering analyzes the cluster against NSA and MITRE guidelines. Apart from these two, Armo themselves have developed two security frameworks for Kubernetes, named ArmoBest and DevOpsBest, which work with Kubescape.

## How does Kubescape work?
Kubescape has capabilities to run inside your cluster as well as in a CI/CD pipeline. This flexibility allows you to keep a constant check on your clusters as well as CI/CD pipelines.

Unlike kube-bench, Kubescape’s tests are not divided into sections. Rather, Kubescape uses controls. In Kubescape’s ecosystem, NSA/MITRE/ArmoBest/DevOpsBest guidelines are broken into small sets of policies (known as controls). Each control has its own set of rules against which the cluster or pipeline is scanned. Using the web interface, you can also create your own framework to use with Kubescape by combining the controls provided on the portal. Once the configuration is scanned, it sends the details to the ARMO’s portal. You can also see the security posture of your cluster/pipeline from the web interface itself. A major difference between kube-bench and Kubescape is that Kubescape goes into specific details, when it comes to check Kubernetes artifacts. On the portal, Kubescape navigates you exactly to the line in a particular artifact/s configuration due to which a control is failing (example has been shared in the image below):


![image](https://user-images.githubusercontent.com/40743779/184465887-7ee5a596-37e8-43c5-8de6-fed0dc7c72e1.png)

If you do not wish to use ARMO’s portal, you can simply scan your cluster/pipeline. The issue with that is you don’t get to schedule your scans natively from Kubescape. However, you can use utilities like cron for that. Following are some examples of CLI output:

# Controls check example
```
[control: Naked PODs - https://hub.armo.cloud/docs/c-0073] failed 😥
Description: It is not recommended to create PODs without parental Deployment, ReplicaSet, StatefulSet etc.Manual creation if PODs may lead to a configuration drift and other untracked changes in the system. Such PODs won't be automatically rescheduled by Kubernetes in case of a crash or infrastructure failure. This control identifies every POD that does not have a corresponding parental object.
Failed:
 Namespace default
   Pod - bus
 Namespace kube-system
   Pod - storage-provisioner
Summary - Passed:22   Excluded:0   Failed:2   Total:24
Remediation: Create necessary Deployment object for every POD making any POD a first class citizen in your IaC architecture.
```
```
[control: Enforce Kubelet client TLS authentication - https://hub.armo.cloud/docs/c-0070] passed 👍
Description: Kubelets are the node level orchestrator in Kubernetes control plane. They are publishing service port 10250 where they accept commands from API server. Operator must make sure that only API server is allowed to submit commands to Kubelet. This is done through client certificate verification, must configure Kubelet with client CA file to use for this purpose.
Summary - Passed:2   Excluded:0   Failed:0   Total:2
```

Summary Example
```
FRAMEWORKS: DevOpsBest (risk: 43.94), MITRE (risk: 15.93), ArmoBest (risk: 27.62), NSA (risk: 30.72)
+-----------------------------------------------------------------------+------------------+--------------------+---------------+--------------+
|                             CONTROL NAME                              | FAILED RESOURCES | EXCLUDED RESOURCES | ALL RESOURCES | % RISK-SCORE |
+-----------------------------------------------------------------------+------------------+--------------------+---------------+--------------+
| Access Kubernetes dashboard                                           |        0         |         0          |      98       |      0%      |
| Access container service account                                      |        41        |         0          |      45       |     91%      |
| Access tiller endpoint                                                |        0         |         0          |       0       |   skipped    |
| Allow privilege escalation                                            |        24        |         0          |      25       |     96%      |
| Allowed hostPath                                                      |        4         |         0          |      25       |     16%      |
.
.
.
.
.
+-----------------------------------------------------------------------+------------------+--------------------+---------------+--------------+
|                           RESOURCE SUMMARY                            |       131        |         0          |      185      |    28.35%    |
+-----------------------------------------------------------------------+------------------+--------------------+---------------+--------------+
```
## Deployment methods
Kubescape can be deployed on any Kubernetes cluster for routine check-ups, as well as in the CI/CD pipeline to ensure that no misconfiguration can make its way to production. It can be run on any machine, given that the kubeconfig file to access the cluster should be present on the machine.

One can install it or run it using a simple set of commands that are available on ARMO’s portal. Once you sign-up on ARMO’s portal, you get an account ID. You also get a set of commands containing this account ID so that all your clusters or CI/CD scans can show up on one single page. The following image shows how do those commands look like:

![image](https://user-images.githubusercontent.com/40743779/184465916-710c67ab-9c43-49b1-a26f-7404b7d84960.png)

If you want to run Kubescape inside an air-gapped Kubernetes cluster, then you can install Kubescape utility from Kubescape’s Github repository and follow the instructions under Offline/Air-gaped Environment Support section present on Kubescape’s Github repository.

## Where it is best to use?
Kubescape can work efficiently on your regular cluster as well as ephemeral clusters (ones created for CI/CD checkup). Kubescape shines when it comes to the configuration of artifacts inside the cluster (in other words, Kubernetes Objects). The reason behind this is the detailed analysis available on ARMO’s portal for every check that gets failed. On ARMO’s portal, you get the issue drilled down to the single line in your configuration due to which a control is failing.

## Integrations
Kubescape natively provides integration with Prometheus, Slack, Jenkins, CircleCI, Github, GitLab, Azure-DevOps, GCP-GKE, AWS-EKS etc.. The steps for integration are well documented at both ARMO’s official docs and Integrations page on ARMO’s portal.

# Conclusion
Both Kubescape and kube-bench are different in terms of what frameworks they support, how they are deployed, and the way they perform scans and provide results. It is better to say that both have their own strong areas. kube-bench proves its mettle when it comes to scanning the host, file permissions and ownership, flags for different Kubernetes control plane components. On the other hand, Kubescape shows its worth when it comes to scanning the objects inside the cluster, such as pods, namespaces, accounts, etc.. Keep in mind that ARMO’s portal is a hosted solution, and for using it, you will have to share information about in-cluster resources with it via Kubescape. However, as we discussed above, you can also use Kubescape in CLI only mode (as mentioned under Offline/Air-gaped Environment Support section in Kubescape’s GitHub repository).

To summarize, I believe both kube-bench and Kubescape complement each other. kube-bench should be used while setting up the cluster or adding up a new host in the cluster, as files permissions and ownership types of things are one-time tasks and it is very important to save the cluster’s configuration from unauthorized access. Once the cluster/new host is up and running, Kubescape could be used for regular scans of artifacts inside the cluster as it drills down the issue to the single line of configuration.












