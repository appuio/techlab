# Lab 7: Troubleshooting whats in the pod?

This lab will shjow you how to deal with errors and troubleshooting, and which toosl are available to you.

## Log in to the container

We use the project from [Lab 4](04_deploy_dockerimage.md) `[USER]-dockerimage`. **Hint:** `oc project [USER]-dockerimage`

Running containers are treated as immutable infrastructure and shouldn't be modified. However there are usecases where you should log in to a container. For example, debugging and analysis.

## Task: LAB7.1

Openshift allows us to open remote shells into pods without installing SSH.

Select a Pod using `oc get pods` and issue the following command:
```
$ oc rsh [POD]
```

You now have a shell within the container and can perfom analyzes:

```
bash-4.2$ ls -la
total 16
drwxr-xr-x. 7 default root   99 May 16 13:35 .
drwxr-xr-x. 4 default root   54 May 16 13:36 ..
drwxr-xr-x. 6 default root   57 May 16 13:35 .gradle
drwxr-xr-x. 3 default root   18 May 16 12:26 .pki
drwxr-xr-x. 9 default root 4096 May 16 13:35 build
-rw-r--r--. 1 root    root 1145 May 16 13:33 build.gradle
drwxr-xr-x. 3 root    root   20 May 16 13:34 gradle
-rwxr-xr-x. 1 root    root 4971 May 16 13:33 gradlew
drwxr-xr-x. 4 root    root   28 May 16 13:34 src
```

## Task: LAB7.2

A single command within the container can be executed using `oc exec`:

```
$ oc exec [POD] env
```


```
$ oc exec example-spring-boot-4-8mbwe env
PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=example-spring-boot-4-8mbwe
KUBERNETES_SERVICE_PORT_DNS_TCP=53
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=172.30.0.1
KUBERNETES_PORT_53_UDP_PROTO=udp
KUBERNETES_PORT_53_TCP=tcp://172.30.0.1:53
...
```

## View log files

The log files for a pod can be displayed in the web console as well as in the cli:

```
$ oc logs [POD]
```
The `-f` parameter has the same behavior as `tail -f`
If a pod has the status **CrashLoopBackOff** this means it could not be started succesfully even after repeated restarts. The logfiles still can be displayed even if the pod is not running with the following command:

 ```
$ oc logs -p [POD]
```

With Openshift an EFK (Elasticsearch, Fluentd, Kibana) stack is delivered, which collects, rotates and aggregates all log files. Kibana allows logs to be searched, filtered and graphically edited. For more information and an optional Lab see [here](../additional-labs/logging_efk_stack.md).

## Task: LAB7.3 Port Forwarding

OpenShift 3 allows us to forward any port from our workstation to the pod. This is usefull to use adminstrationconsoles, databases and so on which should not be exposed towards the internet. In contrast to Openshift 2 the portforwarding is tunneled through the same HTTPS-connection as the Openshift Client (`oc`) uses. This is usefull if there are restrictive Firewalls and/or Proxies between your Workstation and Openshift.

Excercise: Acces the Spring Boot Metrics from [Lab 4](04_deploy_dockerimage.md).

```
oc get po --namespace="[USER]-dockerimage"
oc port-forward example-spring-boot-1-xj1df 9000:9000 --namespace="[USER]-dockerimage"
```

Don't forgett to change the Pod Name accordingly. If installed you can use the TAB-completion.

The Metrics can be found under [http://localhost:9000/metrics/](http://localhost:9000/metrics/). They will be shown in json. With the same concept you could connect a local SQL Client with your database.

Further Documentation to port forwarding can be found under: https://docs.openshift.com/container-platform/3.5/dev_guide/port_forwarding.html

---

**End Lab 7**

<p width="100px" align="right"><a href="08_database.md">Deploy and Attach a Database →</a></p>

[← back to overview](../README.md)
