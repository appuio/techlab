# Troubleshooting and Autoscaling

This lab gives you an overview how to troubleshoot, as well as autoscale applications.

## Troubleshooting

What's in the pod?

This lab shows how to proceed in case of errors and troubleshooting and which tools are available.

## Log in to container

We use the project `develop-[USER]` again. **Tip:** `oc project develop-[USER]`

Running containers are treated as unchangeable infrastructure and should generally not be modified. However, there are use cases where you have to log in to the containers. For example for debugging and analysis.

## Examine a pod

With OpenShift you can open remote shells in the pods without having to install SSH. You can use the `oc rsh` command to do this.

Select a Pod with `oc get pods` and execute the following command:

```bash
oc rsh [POD]
```

You can now use this shell to perform analyses in the container:

```bash
bash-4.2$ ls -la
total 16
drwxr-xr-x. 7 default root 99 May 16 13:35 .
drwxr-xr-x. 4 default root 54 May 16 13:36 ...
drwxr-xr-x. 6 default root 57 May 16 13:35 .gradle
drwxr-xr-x. 3 default root 18 May 16 12:26 .pki
drwxr-xr-x. 9 default root 4096 May 16 13:35 build
-rw-r--r--. 1 root root 1145 May 16 13:33 build.gradle
drwxr-xr-x. 3 root root 20 May 16 13:34 gradle
-rwxr-xr-x. 1 root root 4971 May 16 13:33 gradlew
drwxr-xr-x. 4 root root 28 May 16 13:34 src
```

**Note** Log out of the Pod / Shell with `exit` or `ctrl`+`d`

## Execute commands

Single commands within the container can be executed via `oc exec`:

```bash
oc exec [POD] env
```

```bash
$ oc exec example-spring-boot-4-8mbwe env
PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=example-spring-boot-4-8mbwe
CUBERNET_SERVICE_PORT_DNS_TCP=53
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=172.30.0.1
KUBERNETES_PORT_53_UDP_PROTO=udp
KUBERNETES_PORT_53_TCP=tcp://172.30.0.1:53
...
```

## View Logfiles

The log files for a Pod can be displayed both in the Web Console and in the CLI.

```bash
oc logs [POD]
```

The parameter `-f` causes analogue behavior like `tail -f`.

If a Pod has the status **CrashLoopBackOff** this means that it could not be started successfully even after repeated restarts. The log files can be displayed even if the Pod is not running with the following command.

```bash
oc logs -p [POD]
```

The parameter `-p` stands for "previous", so it refers to a pod of the same DeploymentConfig that was running before, but is stopped now.
Accordingly, this command only works if there was actually a pod before.

OpenShift comes with an EFK (Elasticsearch, Fluentd, Kibana) stack that collects, rotates and aggregates all log files. Kibana allows you to search, filter and graph logs.

Kibana can be reached via the link "Show in Kibana" in the Web-UI at the logs of the Pod. Log in to Kibana, look around and try to define a search for specific logs. Make sure that your actual project is selected underneath `Add a filter`.

Example: mysql Container Logs without error-messages

```bash
kubernetes.container_name:"mysql" AND -message:"error"
```

## Metrics

The OpenShift Platform also integrates a basic set of metrics, which are integrated into the WebUI and used to automatically scale pods horizontally.

With the help of a direct login to a Pod you can now influence the resource consumption of this Pod and observe the effects in the WebUI.

## Forward ports onto your machine

OpenShift allows you to forward arbitrary ports from the development workstation to a Pod. This is useful to access administration consoles, databases, etc. that are not exposed to the Internet and are not reachable otherwise. Port forwarding is tunnelled over the same HTTPS connection that the OpenShift client (oc) uses. This allows access to OpenShift platforms even if there are restrictive firewalls and/or proxies between workstation and OpenShift.

Lab: Accessing the Spring Boot Metrics.

```bash
oc get pod --namespace="develop-[USER]"
oc port-forward example-spring-boot-1-xj1df 9000:9000 --namespace="develop-[USER]"
```

If you are in a single shell (e.g. using the terminal application through the WebUI) your shell is blocked as soon as you start forwarding the port. You can send the forward command to the background by appending an ampersand to it:

```bash
oc port-forward example-spring-boot-1-xj1df 9000:9000 --namespace="develop-[USER]" &
```

Later you will be able to get it back to the foreground by using `fg`:

```bash
$ fg 1
oc port-forward example-spring-boot-1-xj1df 9000:9000 --namespace="develop-[USER]"
^C
```

And then terminating it using CTRL-C.

Don't forget to adapt the Pod name to your own installation. If installed, autocompletion can be used.

The metrics can now be accessed via the following link: [http://localhost:9000/metrics/](http://localhost:9000/metrics/) The Metrics are displayed as JSON. Using the same concept, you can now connect to a database with your local SQL client, for example.

If you are on the WebUI terminal, you can also use curl to see the metrics:

```bash
$ curl http://localhost:9000/metrics/
```

Further information about Port Forwarding can be found in the [documentation](https://docs.openshift.com/container-platform/4.3/nodes/containers/nodes-containers-port-forwarding.html).

**Note:** The `oc port-forward` process will continue until it is aborted by the user. As soon as the port forwarding is no longer needed, it can be stopped with ctrl+c.

## Access inaccessible readyness check

In an earlier task, we set up a readiness check on one /health for the Rolling update strategy. This endpoint could not be reached via the route. How can the endpoint be reached now?

## Autoscaling

In this example we will scale an automated application up and down, depending on how much load the application is under. For this we use our old Ruby example webapp.

Create a new project with the name `autoscale-[USER]`:

```bash
oc new-project autoscale-[USER]
```

On the branch load there is a CPU intensive endpoint which we will use for our tests. Therefore we start the app on this branch:

```bash
oc new-app openshift/ruby:2.5~https://github.com/chrira/ruby-ex.git#load
oc create route edge --insecure-policy=Allow --service=ruby-ex
```

Wait until the application is built and ready and the first metrics appear. You can follow the build as well as the existing pods.

It will take a while until the first metrics appear, then the autoscaler will be able to work properly.

Now we define a set of limits for our application that are valid for a single Pod:
For this we edit the `ruby-ex` DeploymentConfig:

```bash
oc edit dc ruby-ex
```

We add the following resource limits to the container:

```yaml
        resources:
          limits:
            cpu: "0.2"
            memory: "256Mi"
```

The resources are originally empty: `resources: {}`. Attention the `resources` must be defined on the container and not on the deployment.

This will roll out our deployment again and enforce the limits.

As soon as our new container is running we can now configure the autoscaler:

```bash
oc autoscale dc ruby-ex --min 1 --max 3 --cpu-percent=25
```

In the web console we can see that the manual scaling of the pods is no longer possile. Instead we se the values of the autoscaler.

Now we can generate load on the service.

Replace `[HOSTNAME]` with the hostname of your route.

<details><summary>Get Hostname</summary>oc get route -o custom-columns=NAME:.metadata.name,HOSTNAME:.spec.host</details><br/>

```bash
for i in {1..500}; do curl -s https://[HOSTNAME]/load ; done;
```

Every call to the load endpoint should respond with: `Extensive task done`

The current values we can get over:

```bash
oc get horizontalpodautoscaler.autoscaling/ruby-ex
```

Below we can follow our pods:

```bash
oc get pods -w
```

As soon as we finish the load the number of pods will be scaled down automatically after a certain time. However, the capacity is withheld for a while.

## Bonus Question

There is also a `oc idle`command. What is it for?

## Additional exercise for fast ones

The [k8s-debugbox](https://github.com/puzzle/k8s-debugbox) has been developed for troubleshooting containers which are missing debugging tools.

First we try debugging with the oc tool.

### Create project

First create a project called `debugbox-[USER]`.

```bash
oc new-project debugbox-[USER]
```

### Deploy test application

A minimal container image is suitable for testing, e.g. a Go application in an empty file system (From scratch): [s3manager](https://hub.docker.com/r/mastertinner/s3manager)

Create a new application from this image:

* Image: mastertinner/s3manager
* Environment:
  * ACCESS_KEY_ID=something
  * SECRET_ACCESS_KEY=x

```bash
oc new-app -e ACCESS_KEY_ID=something -e SECRET_ACCESS_KEY=x mastertinner/s3manager
```

### Debugging with the oc tool

Try to open a remote shell in the container:

```bash
oc rsh dc/s3manager
```

Error message:

```bash
ERRO[0000] exec failed: container_linux.go:349: starting container process caused "exec: \"/bin/sh\": stat /bin/sh: no such file or directory"
exec failed: container_linux.go:349: starting container process caused "exec: \"/bin/sh\": stat /bin/sh: no such file or directory"
command terminated with exit code 1
```

That didn't work because there is no shell in the container.

Can we at least spend the environment?

```bash
oc exec dc/s3manager env
```

Error message:

```bash
time="2020-04-27T06:25:13Z" level=error msg="exec failed: container_linux.go:349: starting container process caused \"exec: \\\"env\\\": executable file not found in $PATH\""
exec failed: container_linux.go:349: starting container process caused "exec: \"env\": executable file not found in $PATH"
command terminated with exit code 1
```

This is also not possible, the env command is not available.

Even if we try to open the terminal in the web console, we get an error.

We cannot debug this container with the onboard equipment from OpenShift. There is the [k8s-debugbox] (https://github.com/puzzle/k8s-debugbox).

### Install debug box

Install the [k8s-debugbox](https://github.com/puzzle/k8s-debugbox) using the instructions: <https://github.com/puzzle/k8s-debugbox>.

### Apply debug box

Display the options using the help parameter.

Command with output:

```bash
$ k8s-debugbox -h
Debug pods based on minimal images.

Examples:
  # Open debugging shell for the first container of the specified pod,
  # install debugging tools into the container if they aren't installed yet.
  k8s-debugbox pod hello-42-dmj88

...

Options:
  -n, --namespace='': Namespace which contains the pod to debug, defaults to the namespace of the current kubectl context
  -c, --container='': Container name to open shell for, defaults to first container in pod
  -i, --image='puzzle/k8s-debugbox': Docker image for installation of debugging via controller. Must be built from 'puzzle/k8s-debugbox' repository.
  -h, --help: Show this help message
      --add: Install debugging tools into specified resource
      --remove: Remove debugging tools from specified resource

Usage:
  k8s-debugbox TYPE NAME [options]
```

We use the debug box on the s3manager Pod:

<details><summary>Tip to get the pod</summary>oc get pods</details><br/>

```bash
$ k8s-debugbox pod s3manager-1-jw4sl
Uploading debugging tools into pod s3manager-1-hnb6x
time="2020-04-27T06:26:44Z" level=error msg="exec failed: container_linux.go:349: starting container process caused \"exec: \\\"tar\\\": executable file not found in $PATH\""
exec failed: container_linux.go:349: starting container process caused "exec: \"tar\": executable file not found in $PATH"
command terminated with exit code 1

Couldn't upload debugging tools!
Instead you can patch the controller (deployment, deploymentconfig, daemonset, ...) to use an init container with debugging tools, this requires a new deployment though!
```

This attempt also fails because the tools cannot be copied into the container without tar. However, we have received information from the debug box that we should do the installation via deployment. The deployment configuration is expanded with an init container. The init container copies the tools into a volume, which can then be used by the s3manager container.

Patching the deployment configuration:

```bash
k8s-debugbox dc s3manager
```

Here is the init container extract from the patched deployment configuration:

```yaml
spec:
  template:
    spec:
      initContainers:
      - image: puzzle/k8s-debugbox
        name: k8s-debugbox
        volumeMounts:
        - mountPath: /tmp/box
          name: k8s-debugbox
```

After another deployment of the pod, we are in a shell in the container. We have a variety of tools at our disposal. Now we can do the debugging.

Where are the debugging tools located?

<details><summary>Solution</summary>/tmp/box/bin/</details><br/>

**Tip** By entering `exit` we end the debug box.

How can we undo the changes to the DeploymentConfiguration?

<details><summary>Solution</summary>k8s-debugbox dc s3manager --remove</details><br/>
