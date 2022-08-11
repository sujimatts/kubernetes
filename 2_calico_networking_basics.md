## Calico for Kubernetes networking: the basics & examples

# A quick introduction to Kubernetes networking
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

To allow it, use:
```
podSelector: {}
  egress:
  - {}
  policyTypes:
  - Egress
```
But let’s get back to the problem of selecting a suitable CNI plugin for the cluster. It is worth noting that not every network plugin supports NetworkPolicy API. For example, Flannel cannot configure network policies, which is explicitly stated in the official repository. The Flannel developers kindly suggest an alternative — Calico, the Open Source project that significantly extends the features of the built-in Kubernetes API in terms of network policies.

![image](https://user-images.githubusercontent.com/40743779/184136552-7d61e056-4ec3-4714-91d0-3fb32c0f2364.png)

## Intro to Calico: a bit of theory
You can use the Calico plugin as a stand-alone tool or with Flannel (via Canal subproject) to implement network connectivity features and to manage accessibility.

What are the advantages of using the built-in Kubernetes features together with the Calico APIs?

Well, here is the list of NetworkPolicy’s features:

    policies are limited to an environment;
    policies are applied to pods marked with labels;
    you can apply rules to pods, environments or subnets;
    the rules may contain protocols, numerical or named ports.
    
And here is how Calico extends these features:

    policies can be applied to any object: pod, container, virtual machine or interface;
    the rules can contain the specific action (restriction, permission, logging);
    you can use ports, port ranges, protocols, HTTP/ICMP attributes, IPs or subnets (v4 and v6), any selectors (selectors for nodes, hosts, environments) as a source or a target of the rules;
    also, you can control traffic flows via DNAT settings and policies for traffic forwarding.

The first commits to the Calico repository on GitHub were made in July 2016, and, within a year, the project established itself as a leader in the field of Kubernetes network connectivity. For example, here are the results of a survey conducted by The New Stack in 2017:

![image](https://user-images.githubusercontent.com/40743779/184136820-43e5605f-b7f3-4a03-9060-2a0d247b6987.png)


## Using Calico
In the general case of plain vanilla Kubernetes, installing the CNI boils down to applying (kubectl apply -f) the calico.yaml manifest downloaded from the official site of the project.

Usually, the most recent version of the plugin is compatible with at least 2–3 latest versions of Kubernetes. Its reliable operation in older versions isn’t tested and is not guaranteed. According to developers, Calico supports Linux kernels starting with 3.10 running under CentOS 7, Ubuntu 16, or Debian 8 with iptables/IPVS as a basis.

## Isolation inside the environment
For general understating, let’s consider an elemental case to see how Calico network policies differ from regular ones and how the approach to composing rules improves their readability and configuration flexibility.

![image](https://user-images.githubusercontent.com/40743779/184136929-31cb9e5f-bd8c-41ad-9caf-9fbc178edd98.png)


We have two web applications in the cluster, Node.js-based and PHP-based. One of them uses a Redis database. To prevent access to Redis from PHP while preserving connectivity with Node.js, you can apply the following policy:
```
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: allow-redis-nodejs
spec:
  podSelector:
    matchLabels:
      service: redis
  ingress:
  - from:
    - podSelector:
        matchLabels:
          service: nodejs
    ports:
    - protocol: TCP
      port: 6379
```
Essentially, we allowed incoming traffic from Node.js to the Redis port. We did not block the rest of the traffic explicitly. However, once we define the NetworkPolicy, all the selectors mentioned in it become isolated (unless we specify otherwise). At the same time, isolation rules do not apply to objects which are not covered by the selector.

In our example, we use out-the-box Kubernetes apiVersion, but you can use the same resource from Calico. The syntax is more detailed there, so you need to rewrite the rule for the above case in the following form:

```
apiVersion: crd.projectcalico.org/v1
kind: NetworkPolicy
metadata:
  name: allow-redis-nodejs
spec:
  selector: service == 'redis'
  ingress:
  - action: Allow
    protocol: TCP
    source:
      selector: service == 'nodejs'
    destination:
      ports:
      - 6379
```

The above expressions for allowing or denying all traffic via the regular NetworkPolicy API contain constructions with curly/square brackets, challenging for perceiving and remembering. In the case of Calico, you can easily alter the logic of a firewall rule to the opposite by replacing action: Allow with action: Deny.

## Isolation through environments
Now, suppose that an application generates business metrics for collecting them in Prometheus and further analysis with Grafana. Metrics might include some sensitive data that is unprotected and is available for all to see by default. Let’s protect that data:

![image](https://user-images.githubusercontent.com/40743779/184137177-469e902b-d33c-4732-99a6-88e06cf993f7.png)


Usually, Prometheus runs in a separate service environment. In our example, we have the following namespace:
```
apiVersion: v1
kind: Namespace
metadata:
  labels:
    module: prometheus
  name: kube-prometheus
```
The metadata.labels field plays an important role here. As mentioned above, namespaceSelector (as well as podSelector) works with labels. Therefore, you have to add a new label (or use the existing one) to enable collecting metrics from all pods on a particular port, and then apply a configuration like that:
```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-metrics-prom
spec:
  podSelector: {}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          module: prometheus
    ports:
    - protocol: TCP
      port: 9100
```
And in the case of Calico policies, the syntax would be as it follows:
```
apiVersion: crd.projectcalico.org/v1
kind: NetworkPolicy
metadata:
  name: allow-metrics-prom
spec:
  ingress:
  - action: Allow
    protocol: TCP
    source:
      namespaceSelector: module == 'prometheus'
    destination:
      ports:
      - 9100
```

Basically, by adding this kind of policy customized to specific needs, you can protect yourself against malicious or accidental interference in the operation of applications in the cluster.

Calico developers adhere to the Default Deny principle, meaning that all traffic is denied by default unless explicitly allowed. They articulate their position in the official documentation (others follow a similar approach, as is evident in the already mentioned article).

