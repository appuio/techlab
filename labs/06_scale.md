# Lab 6: Pod Scaling, Readiness Probe und Self Healing

In this lab we will show you how to scale applications in OpenShift. We also show how OpenShift ensures that the number of expected pods is started and how an application can report back to the platform that it is ready for requests.

## Scale up Example Application

We are creating a new project

```
$ oc new-project [USER]-scale
```

And add an application to the project

```
$ oc new-app appuio/example-php-docker-helloworld --name=appuio-php-docker
```

And provide the service (expose)

```
$ oc expose service appuio-php-docker
```

If we want to scale our Example application, we must tell our ReplicationController (rc) that we want to have 3 replicas of the image running at the same time.

Let's take a closer look at the ReplicationController (rc):

```
$ oc get rc

NAME                  DESIRED   CURRENT   AGE
appuio-php-docker-1   1         1         33s
```

For more details:

```
$ oc get rc appuio-php-docker-1 -o json
```

The rc tells us how many pods we expect (spec) and how many are currently deployed (status).

## Task: LAB6.1 scale our sample application

Now we scale our Example application on 3 replicas:

```
$ oc scale --replicas=3 dc appuio-php-docker
```

Let us check the number of replicas on the ReplicationController:

```bash
$ oc get rc

NAME                  DESIRED   CURRENT   AGE
appuio-php-docker-1   3         3         1m

```

And accordingly indicate the pods:

```
$ oc get pods
NAME                        READY     STATUS    RESTARTS   AGE
appuio-php-docker-1-2uc89   1/1       Running   0          21s
appuio-php-docker-1-evcre   1/1       Running   0          21s
appuio-php-docker-1-tolpx   1/1       Running   0          2m

```

Finally, look at the service. This should now reference all three endpoints:
```
$ oc describe svc appuio-php-docker
Name:			appuio-php-docker
Namespace:		techlab-scale
Labels:			app=appuio-php-docker
Selector:		app=appuio-php-docker,deploymentconfig=appuio-php-docker
Type:			ClusterIP
IP:				172.30.166.88
Port:			8080-tcp	8080/TCP
Endpoints:		10.1.3.23:8080,10.1.4.13:8080,10.1.5.15:8080
Session Affinity:	None
No events.

```

Scaling pods within a service is very fast as OpenShift simply starts a new instance of the docker image as a container.

**Hint:** OpenShift V3 also supports autocaling, the documentation can be found at the following link: : https://docs.openshift.com/container-platform/3.5/dev_guide/pod_autoscaling.html

## Task: LAB6.2 scaled app in the web console

Look at the scaled application in the Web Console.

## Check interruption-free scaling

With the following command you can check the availability of your service when scaling it up and down.
Replace `[route]` with the name of your route:

**Hint:** oc get route

```bash
while true; do sleep 1; curl -s http://[route]/pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

or if you use PowerShell (> 3.0!):

```powershell
while(1) {
	Start-Sleep -s 1
	Invoke-RestMethod http://[route]/pod/
	Get-Date -Uformat "+ TIME: %H:%M:%S,%3N"
}
```

scale from **3** Replicas to **1**.
the output shows the responding pod:

```bash
POD: appuio-php-docker-6-9w9t4 TIME: 16:40:04,991
POD: appuio-php-docker-6-9w9t4 TIME: 16:40:06,053
POD: appuio-php-docker-6-6xg2b TIME: 16:40:07,091
POD: appuio-php-docker-6-6xg2b TIME: 16:40:08,128
POD: appuio-php-docker-6-ctbrs TIME: 16:40:09,175
POD: appuio-php-docker-6-ctbrs TIME: 16:40:10,212
POD: appuio-php-docker-6-9w9t4 TIME: 16:40:11,279
POD: appuio-php-docker-6-9w9t4 TIME: 16:40:12,332
POD: appuio-php-docker-6-6xg2b TIME: 16:40:13,369
POD: appuio-php-docker-6-6xg2b TIME: 16:40:14,407
POD: appuio-php-docker-6-6xg2b TIME: 16:40:15,441
POD: appuio-php-docker-6-6xg2b TIME: 16:40:16,493
POD: appuio-php-docker-6-6xg2b TIME: 16:40:17,543
POD: appuio-php-docker-6-6xg2b TIME: 16:40:18,591
```

The Requests are delegated to the differend pods, as soon as you scale down to only one Pod, it's the only one answering:

We now want to see, what is happening, if we start a new deployment. During a short time, we see, that nothing is answering:

```bash
$ oc rollout latest appuio-php-docker
POD: appuio-php-docker-6-6xg2b TIME: 16:42:17,743
POD: appuio-php-docker-6-6xg2b TIME: 16:42:18,776
POD: appuio-php-docker-6-6xg2b TIME: 16:42:19,813
POD: appuio-php-docker-6-6xg2b TIME: 16:42:20,853
POD: appuio-php-docker-6-6xg2b TIME: 16:42:21,891
POD: appuio-php-docker-6-6xg2b TIME: 16:42:22,943
POD: appuio-php-docker-6-6xg2b TIME: 16:42:23,980
# keine Antwort
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:42,134
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:43,181
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:44,226
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:45,259
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:46,297
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:47,571
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:48,606
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:49,645
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:50,684
```

It this example we are using a light weight pod. If we would to the same with our application from Lab 4, wich is a Java Application we would see a startup time from around **30 Seconds**.

```
Pod: example-spring-boot-2-73aln TIME: 16:48:25,251
Pod: example-spring-boot-2-73aln TIME: 16:48:26,305
Pod: example-spring-boot-2-73aln TIME: 16:48:27,400
Pod: example-spring-boot-2-73aln TIME: 16:48:28,463
Pod: example-spring-boot-2-73aln TIME: 16:48:29,507
<html><body><h1>503 Service Unavailable</h1>
No server is available to handle this request.
</body></html>
 TIME: 16:48:33,562
<html><body><h1>503 Service Unavailable</h1>
No server is available to handle this request.
</body></html>
 TIME: 16:48:34,601
 ...
Pod: example-spring-boot-3-tjdkj TIME: 16:49:20,114
Pod: example-spring-boot-3-tjdkj TIME: 16:49:21,181
Pod: example-spring-boot-3-tjdkj TIME: 16:49:22,231

```

It may even be that the service is no longer online and the routing layer returns a **503 Error**.

It may even be that the service is no longer online and the routing layer returns a **503 Error**.

## Interruption-free deployment using Readiness Probe and Rolling Update

The update strategy [Rolling](https://docs.openshift.com/container-platform/3.5/dev_guide/deployments/deployment_strategies.html#rolling-strategy) allows interruption-free deployments. This will start the new version of the application as soon as the application is ready, Request will be routed to the new pod, and the old version will be undeployed.

In addition, using [Container Health Checks](https://docs.openshift.com/container-platform/3.5/dev_guide/application_health.html) he deployed application of the platform can provide detailed feedback on its current state.

Basically, there are two checks that can be implemented:

- Liveness Probe, says whether a running container is still running clean.
- Readiness Probe, provides feedback on whether an application is ready to receive requests. Is especially relevant in the Rolling Update.

These two checks can be implemented as HTTP Check, Container Execution Check (Shell Script in Container) or TCP Socket Check.

In our example, the platform application is to say whether it is ready for requests. For this, we use the Readiness Probe. Our example application returns a status code 200 on port 9000 (management port of the spring application) as soon as the application is ready.

```
http://[route]/health/
```

## Task: LAB6.3

In der Deployment Config (dc) definieren im Abschnitt der Rolling Update Strategie, dass bei einem Update die App immer verfügbar sein soll: `maxUnavailable: 0%`

This can be configured in the Deployment Config (dc):

**YAML:**

```yaml
...
spec:
  strategy:
    type: Rolling
    rollingParams:
      updatePeriodSeconds: 1
      intervalSeconds: 1
      timeoutSeconds: 600
      maxUnavailable: 0%
      maxSurge: 25%
    resources: {  }
...
```

The Deployment Config can be edited via Web Console (Applications → Deployments → example-php-docker-helloworld, edit) or directly via `oc`.
```
$ oc edit dc appuio-php-docker
```

Or edit it in the json format:

```bash
$ oc edit dc appuio-php-docker -o json
```

**json**:

```json
"strategy": {
    "type": "Rolling",
    "rollingParams": {
          "updatePeriodSeconds": 1,
          "intervalSeconds": 1,
          "timeoutSeconds": 600,
          "maxUnavailable": "0%",
          "maxSurge": "25%"
    },
    "resources": {}
}

```

The Readiness Probe must be added to the Deployment Config (dc) at:

spec --> template --> spec --> containers jus under `resources: {  }`

**YAML:**

```yaml
...
          resources: {  }
          readinessProbe:
            httpGet:
              path: /health/
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 10
            timeoutSeconds: 1
...
```

**json:**

```json
...
                        "resources": {},
                        "readinessProbe": {
                            "httpGet": {
                                "path": "/health/",
                                "port": 8080,
                                "scheme": "HTTP"
                            },
                            "initialDelaySeconds": 10,
                            "timeoutSeconds": 1
                        },
...
```

Adjust this accordingly as above.

The configuration under `containers` should look as the following:
**YAML:**

```yaml
      containers:
        -
          name: example-php-docker-helloworld
          image: 'appuio/example-php-docker-helloworld@sha256:6a19d4a1d868163a402709c02af548c80635797f77f25c0c391b9ce8cf9a56cf'
          ports:
            -
              containerPort: 8080
              protocol: TCP
          resources: {  }
          readinessProbe:
            httpGet:
              path: /health/
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 10
            timeoutSeconds: 1
          terminationMessagePath: /dev/termination-log
          imagePullPolicy: IfNotPresent
```

**json:**

```json
                "containers": [
                    {
                        "name": "appuio-php-docker",
                        "image": "appuio/example-php-docker-helloworld@sha256:9e927f9d6b453f6c58292cbe79f08f5e3db06ac8f0420e22bfd50c750898c455",
                        "ports": [
                            {
                                "containerPort": 8080,
                                "protocol": "TCP"
                            }
                        ],
                        "resources": {},
                        "readinessProbe": {
                            "httpGet": {
                                "path": "/health/",
                                "port": 8080,
                                "scheme": "HTTP"
                            },
                            "initialDelaySeconds": 10,
                            "timeoutSeconds": 1
                        },
                        "terminationMessagePath": "/dev/termination-log",
                        "imagePullPolicy": "Always"
                    }
                ],
```

Verify during a deployment of the application whether an update of the application now runs without interruption:

A request per second:

```bash
while true; do sleep 1; curl -s http://[route]/pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

Start the deployments:

```bash
oc rollout latest appuio-php-docker
```

## Self Healing

Through the Replication Controller, we have now told the platform that n replicas are to run. What happens if we delete a pod?

Use `oc get pods` o find a pod in the status "running", which you can *kill*.

Start the following command in a separate terminal (display the changes to pods)

```bash
oc get pods -w
```

In the other terminal, delete a pod with the following command

```bash
oc delete pod appuio-php-docker-3-788j5
```

OpenShift ensures that again **n** replicas of the mentioned pod are running.


---

**End Lab 6**

<p width="100px" align="right"><a href="07_troubleshooting_ops.md">Troubleshooting what's in the pod? →</a></p>

[← back to overview](../README.md)
