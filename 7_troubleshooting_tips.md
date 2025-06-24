![k8s-troubleshooting-tips](https://github.com/user-attachments/assets/d7ed61eb-5f7c-489d-972b-1c9ecf2e14b6)

## 🟦 POD DIAGNOSTICS

### 1. Pod State Checks

```bash
kubectl get pods
```

- Check for `PENDING` status  
- Check for `RUNNING` status  
- Check for `READY` status

---

### 2. If Pod is PENDING

- **Is the cluster full?**  
  → Provision a bigger cluster

- **Hitting ResourceQuotas?**  
  → Relax ResourceQuota limits

- **PersistentVolumeClaims issues?**  
  → Fix PVC

- **Is the Pod assigned to a Node?**
  - If **not** → kubelet/scheduler issue
  - If **yes** but still pending → Consult:
    ```bash
    kubectl describe pod <pod-name>
    ```

---

### 3. If Pod is RUNNING but not READY

- Check liveness/readiness probes:
  ```bash
  kubectl describe pod <pod-name>
  ```

- Check logs:
  ```bash
  kubectl logs <pod-name>
  kubectl logs <pod-name> --previous
  ```

- Check for imagePull errors or private registry access issues

- `CrashLoopBackOff`?  
  → Investigate app logs, Dockerfile, image tags, or entrypoint

---

### 4. Accessing the Pod

```bash
kubectl port-forward <pod-name> 8080:<pod-port>
```

- Check if the app is reachable at `0.0.0.0`  
- If not → Fix container port / expose correct interface

---

## 🟨 SERVICE DIAGNOSTICS

### 1. Check Endpoints

```bash
kubectl describe service <service-name>
```

- Can you see a list of **endpoints**?

#### If **NO**, then:

- **Selector mismatch** with Pod labels → Fix selector  
- **Pod not assigned to a Node** → kubelet issue  
- **Controller Manager** issue

---

### 2. Accessing the Service

```bash
kubectl port-forward service/<service-name> 8080:<service-port>
```

- Is the `targetPort` in Service matching `containerPort`?

→ If **not**, update `containerPort` in pod spec

---

## 🟩 INGRESS DIAGNOSTICS

### 1. Describe Ingress

```bash
kubectl describe ingress <ingress-name>
```

- Can you see list of **Backends**?  
- Are the **ServiceName** and **ServicePort** matching the Service?

---

### 2. Accessing the Ingress

```bash
kubectl port-forward <ingress-pod-name> 8080:<ingress-port>
```

- Can you visit the app via browser or curl?

---

### 3. Exposure

If the app still doesn’t work:

- Check how the **cluster is exposed** (LoadBalancer/NodePort)
- Check if **DNS entry** or **LoadBalancer config** is correct

---

## ✅ FINAL STATES CHECK

- ✅ **Pods are running correctly**  
  → If readiness/liveness probes are OK and logs are clean

- ✅ **The Service is running correctly**  
  → If endpoints are present and `port-forward` works

- ✅ **The Ingress is running correctly**  
  → If ingress routes correctly and DNS/load balancer is configured
