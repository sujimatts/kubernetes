## Understanding Jobs in Kubernetes

Jobs and Cron Jobs are very important parts of Kubernetes workloads. These Jobs help us to perform a particular task which we assigned to them.

The main difference between a Job and a Cron Job is, a Job will perform a given task and once it’s completed it will stop the process and the Job runs only when we need it to run. Cron Job also does the same thing but we can schedule a Cron Job to run at a given schedule. For instance, we can schedule a Cron Job to run once every hour or we can schedule it to run at 6 am daily.

In this article, I will talk about Jobs and how to configure a Job inside your application.

## Configuring a job

As you already know, we use YAML files to configure Kubernetes components inside the cluster and make changes to the existing components. Here also, we can use a YAML configuration file to create a Job in Kubernetes. Let’s see a simple Job configuration file.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: node-app-job
spec:
  template:
    spec:
      containers:
      - name: node-app-job
        image: alpine   #your docker image
        command: ["echo", "Welcome to my Node app"]
      restartPolicy: Never
```
The above code, snippet represents a simple Kubernetes Job configuration file and you can add your docker image to the job configuration file. After you create the Job as above, you can apply it to the cluster using the below command.

```
$ kubectl apply -f node-app-job.yaml

```
Run the ```kubectl get all``` command on terminal and you will see there, the job has been created. This process may take some time when you do this for the first time since it takes some time to pull your docker image from the container registry.

Run ```kubectl get pod --watch``` to see events so that you can observe if there’s an error when creating the job.

To see the logs of your Job, run the below command using the pod name obtained from ```kubectl get all``` command on the terminal.

```$ kubectl logs <pod-name>```

You will see Welcome to my Node app as the output as we configured the command in the above confirmation file. You can use the ```kubectl describe job <job-name> ```command to get more details about your Job.


## Changing the job configuration file

Unlike deployments and services in Kubernetes, you can’t change the same job configuration file and reapply it at once. When you made changes in the Job configuration file and before you apply it to the cluster, you need to delete the previous job from the cluster.

Use the below command to remove the Job from the cluster.

```
$ kubectl delete job <job-name>
//example
> kubectl delete job node-app-job
job.batch "node-app-job" deleted
```

Run ```kubectl get all``` command and make sure you’ve successfully deleted the previous job from the cluster. Then you can run the ```kubectl apply``` command again and check the logs.

Let’s change the job configuration file first and investigate the logs.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: node-app-job
spec:
  template:
    spec:
      containers:
      - name: node-app-job
        image: alpine
        command: ["ls"]
      restartPolicy: Never
```

I changed the command in the configuration file and this will output the directories in the alpine docker image. Also, you can change the docker image and the command as you prefer.

## completions & parallelism

Generally, when we create a Job, it creates a single pod and performs the given task. You’ve already experienced it via the above example. But using completions we can initiate several pods one after the other.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: node-app-job
spec:
  completions: 2
  template:
    spec:
      containers:
      - name: node-app-job
        image: alpine
        command: ["echo", "Welcome to my Node app"]
      restartPolicy: Never
```

Once you added ```completions``` you’ll see two pods are created for this job. Use the ```kubectl get pods --watch``` command to see them.

```
// kubectl get pods --watch output
pod/node-app-deployment-5c4694f5b-7tf8r   1/1     Running
pod/node-app-job-7pdp9                    0/1     Completed
pod/node-app-job-9924d                    0/1     ContainerCreating
```

You can use ```parallelism``` to run multiple pods at the same time. parallelism also used under the spec as below.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: node-app-job
spec:
  completions: 2
  parallelism: 2
  template:
    spec:
      containers:
      - name: node-app-job
        image: alpine
        command: ["echo", "Welcome to my Node app"]
      restartPolicy: Never
```

You can set the maximum number of pods you need to run for this particular job under the ```completions``` and you can define how many pods should run parallelly under the ```parallelism```.

In the above code block, we’ve got 2 pods and we need both the pods to run parallelly.

```
// kubectl get pods --watch output
pod/node-app-deployment-5c4694f5b-7tf8r   1/1     Running
pod/node-app-job-glcn4                    0/1     ContainerCreating
pod/node-app-job-ngm5p                    0/1     ContainerCreating
```

## backoffLimit & activeDeadlineSeconds

```backoffLimit``` help us to limit the pod creation when our job fails to create successfully. Usually, when a pod doesn’t create properly, it will go to the ```Error``` status and initiate another pod and this process continues until you get a successfully created pod.

If your job contains something(ex: command error) that doesn’t allow your job to create successfully, it tries creating pods continuously. When you run ```kubectl get pods``` you’ll see several pods with Error status. But using ```backoffLimit``` you can limit the number of pods created continuously.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: node-app-job
spec:
  backoffLimit: 2
  template:
    spec:
      containers:
      - name: node-app-job
        image: alpine
        command: ["ls", "/data"]
      restartPolicy: Never
```

```
kubectl get pods
pod/node-app-deployment-5c4694f5b-7tf8r   1/1     Running
pod/node-app-job-8bfgj                    0/1     Error
pod/node-app-job-kk8nh                    0/1     Error
pod/node-app-job-x6fmk                    0/1     Error
```

```activeDeadlineSeconds``` help us to decide how many seconds should the job run. To verify this option we set sleep command inside our job to run it for 40 seconds. But using ```activeDeadlineSeconds: 15``` we can terminate the job after 15 seconds.

```

apiVersion: batch/v1
kind: Job
metadata:
  name: node-app-job
spec:
  activeDeadlineSeconds: 15
  template:
    spec:
      containers:
      - name: node-app-job
        image: alpine
        command: ["sleep", "40"]
      restartPolicy: Never
```

![image](https://user-images.githubusercontent.com/40743779/183361725-cee2bf02-da1e-47c2-909e-ffbb8bd6829a.png)
