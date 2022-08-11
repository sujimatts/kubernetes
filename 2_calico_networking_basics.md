A quick introduction to Kubernetes networking
The network is an integral part of every Kubernetes cluster. There are many in-depth articles describing the fundamentals of Kubernetes networking, such as An illustrated guide to Kubernetes Networking or An Introduction to Kubernetes Network Policies for Security People.

In the context of this article, it should be noted that K8s isn’t responsible for network connectivity between containers: for this, various CNI (Container Networking Interface) plugins are used.

For example, the most popular of such plugins, Flannel, enables full network connectivity between all cluster nodes by running a small binary agent on each node. With it, Flannel allocates a subnet to each host. However, full and unregulated network accessibility is not always good. To ensure minimum isolation in the cluster, you have to deal with the firewall configuration. Generally, the CNI itself is in charge of such a configuration, that is why any third-party attempts to modify iptables rules might be interpreted incorrectly or ignored altogether.

Out-of-the-box, Kubernetes provides NetworkPolicy API for managing network policies in the cluster. This resource is applied to selected namespaces and may contain rules for limiting access of one application to another. It also provides means for configuring accessibility of specific pods, environments (namespaces), or IP-address blocks:
```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - ipBlock:
        cidr: 172.17.0.0/16
        except:
        - 172.17.1.0/24
    - namespaceSelector:
        matchLabels:
          project: myproject
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 6379
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/24
    ports:
    - protocol: TCP
      port: 5978
```

The above not-so-basic example from the official documentation might discourage you once and for all from trying to understand the logic of operation of network policies. Let’s try to sift through the basic principles and methods of processing traffic flows using network policies.

As you can easily guess, there are two types of traffic: incoming to pod (Ingress) and outgoing from it (Egress).

![image](https://user-images.githubusercontent.com/40743779/184136212-708dffea-5509-4fbc-99a9-cae26426091b.png)

Obviously, the policy is divided into two categories depending on the direction of traffic.

The selector is the next mandatory attribute: each rule is applied to some selector(s). It could represent a pod (or a group of pods), or an environment (i.e., a namespace). An important feature is that both types of above objects must contain a label since policies operate on these labels.

In addition to the finite number of selectors united by some label, you can define broader rules such as “Allow/Deny everything/to all” in different variations. For this, the following expressions are used:

```
podSelector: {}
  ingress: []
  policyTypes:
  - Ingress
```
In the above example, all pods of an environment are blocked from incoming traffic. You can achieve the opposite behavior with this expression:
```
podSelector: {}
  ingress:
  - {}
  policyTypes:
  - Ingress
```  

And here is the same expression for denying outgoing traffic:
```
podSelector: {}
  policyTypes:
  - Egress
 ```
 
