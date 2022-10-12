
## Persistent Volume Claim for StatefulSet
Sometimes, we need the configuration to persist so that when the pod restarts the same configuration can be applied. We typically request a Persistent Volume Claim (PVC) through the storage provider to create the Persistent Volume (PV), and we can mount it to the pod container.

## Use PV in Deployment
Apply the following yaml file to create a PVC
