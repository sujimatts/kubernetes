
## Persistent Volume Claim for StatefulSet
Sometimes, we need the configuration to persist so that when the pod restarts the same configuration can be applied. We typically request a Persistent Volume Claim (PVC) through the storage provider to create the Persistent Volume (PV), and we can mount it to the pod container.

## Use PV in Deployment
Apply the following yaml file to create a PVC
```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-persistent-cfg
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Mi
  #storageClassName: yourClass
```
If you don’t specify the ```storageClassName```, the PVC will use the default storage class to create the PV and bind it.

2. Create the deployment

Once you have the PVC defined, you can apply it in your deployment.
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: busybox
        volumeMounts:
          - name: pv-data
            mountPath: /data
      volumes:
        - name: pv-data
          persistentVolumeClaim:
            claimName: pvc-persistent-cfg
        #emptyDir: {}
```
Here we define a volume called as pv-datausing PVC pvc-persistent-cfg , and mount it into the container to the mounting point of /data .

## Potential Problem

The above K8s deployment works fine if we have only one single replica. However, if there were multiple replicas running, you will encounter problems.

First, the ReadWriteOnce won’t allow you to mount the same PV to a different node. See the following quote from Kubernetes document

```ReadWriteOnce``` — the volume can be mounted as read-write by a single node

```ReadOnlyMany``` — the volume can be mounted read-only by many nodes

```ReadWriteMany``` — the volume can be mounted as read-write by many nodes

Secondly, even you use ```ReadWriteMany``` to allow it to be able to run across multiple nodes and your underlining storage class support it, your application must be able to handle the concurrent read-write of the same file. You don’t want your developers to handle the deployment related requirement.
