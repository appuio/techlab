# Develop Application

In this lab we will deploy the first "pre-built" Docker Image and take a closer look at the OpenShift concepts Pod, Service, DeploymentConfig and ImageStream.

## Task

After using the Source-to-Image workflow as well as a binary and docker build to deploy an application to OpenShift, we will now deploy a pre-built docker image from DockerHub or another docker registry.

> [Further Documentation](https://docs.openshift.com/container-platform/4.3/applications/application_life_cycle_management/creating-applications-using-cli.html#applications-create-using-cli-modify_creating-applications-using-cli)

As a first step we create a new project.

Therefore, create a new project with the name `develop-userXY`:

```
$ oc new-project develop-userXY
```

`oc new-project` automatically changes to the newly created project. With `oc get` command, resources of a certain type can be displayed.

Use

```
$ oc get project
```

to list all the projects you have access to.

Once the new project has been created, we can deploy the Docker image in OpenShift with the following command:

```
$ oc new-app appuio/example-spring-boot
```

Output:

```bash
--> Found container image 110b441 (11 days old) from Docker Hub for "appuio/example-spring-boot"

    APPUiO Spring Boot App
    ----------------------
    Example Spring Boot App

    Tags: builder, springboot

    * An image stream tag will be created as "example-spring-boot:latest" that will track this image
    * This image will be deployed in deployment config "example-spring-boot"
    * Ports 8080/tcp, 8778/tcp, 9000/tcp, 9779/tcp will be load balanced by service "example-spring-boot"
      * Other containers can access this service through the hostname "example-spring-boot"

--> Creating resources ...
    imagestream.image.openshift.io "example-spring-boot" created
    deploymentconfig.apps.openshift.io "example-spring-boot" created
    service "example-spring-boot" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose svc/example-spring-boot'
    Run 'oc status' to view your app.
```

For our lab we use an APPUiO example(Java Spring Boot Application):
- Docker Hub: https://hub.docker.com/r/appuio/example-spring-boot/
- GitHub (Source): https://github.com/appuio/example-spring-boot-helloworld

OpenShift creates the necessary resources, downloads the Docker image from Docker Hub and deploys the corresponding Pod.

**Tipp:** Use `oc status` to get an overview of current project.

Alternatively, use `oc get` command with `-w` Parameter, to see ongoing changes of resources with type pod (cancel with ctrl+c):
```
$ oc get pods -w
```

Depending on your internet connection or whether the image on your OpenShift Node has already been downloaded, this may take a while. Check the current status of the deployment in the Web Console:

1. Log in to the Web Console
2. Select your project `develop-userXY`.
3. Click on Applications
4. Select Pods

**Tip** To create your own Docker Images for OpenShift, you should follow these [best practices](https://docs.openshift.com/container-platform/4.3/openshift_images/create-images.html#images-create-guide-general_create-images).

## Viewing the created resources

When we were running `oc new-app appuio/example-spring-boot` earlier, OpenShift created some resources for us in the background. They are needed to deploy this Docker image:

- [Service](https://docs.openshift.com/container-platform/3.11/architecture/core_concepts/pods_and_services.html#services)
- [ImageStream](https://docs.openshift.com/container-platform/4.3/openshift_images/images-understand.html)
- [Deployments and DeploymentConfigs](https://docs.openshift.com/container-platform/4.3/applications/deployments/what-deployments-are.html)

### Service

[Services](https://docs.openshift.com/container-platform/3.11/architecture/core_concepts/pods_and_services.html#services) serve within OpenShift as an abstraction layer, entry point and proxy/load balancer to the underlying pods. The service makes it possible to find and address a group of pods of the same type within OpenShift.

As an example: If an application instance in our example can no longer handle the load alone, we can upscale the application to three pods, for example. OpenShift automatically maps these as endpoints to the service. As soon as the pods are ready, requests are automatically distributed to all three pods.

**Note:** The application cannot yet be reached from the outside, the service is an OpenShift internal concept. In the following lab we will make the application publicly available.

Now let's take a closer look at our service:

```
$ oc get services
```

```
NAME                  CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
example-spring-boot   172.30.124.20   <none>        8080/TCP   2m
```

As you can see from the output, our service (example-spring-boot) is reachable via an IP and port (172.30.124.20:8080) **Note:** Your IP can be different.

**Note:** Service IPs always remain the same during their lifetime.

You can use the following command to read additional information about the service:

```
$ oc get service example-spring-boot -o json
```

```json
{
    "apiVersion": "v1",
    "kind": "Service",
    "metadata": {
        "annotations": {
            "openshift.io/generated-by": "OpenShiftNewApp"
        },
        "creationTimestamp": "2020-04-19T19:25:22Z",
        "labels": {
            "app": "example-spring-boot",
            "app.kubernetes.io/component": "example-spring-boot",
            "app.kubernetes.io/instance": "example-spring-boot"
        },
        "name": "example-spring-boot",
        "namespace": "develop-user",
        "resourceVersion": "244259194",
        "selfLink": "/api/v1/namespaces/develop-user/services/example-spring-boot",
        "uid": "832fc8e9-8273-11ea-82eb-06f8086ebf8c"
    },
    "spec": {
        "clusterIP": "172.30.151.26",
        "ports": [
            {
                "name": "8080-tcp",
                "port": 8080,
                "protocol": "TCP",
                "targetPort": 8080
            },
            {
                "name": "8778-tcp",
                "port": 8778,
                "protocol": "TCP",
                "targetPort": 8778
            },
            {
                "name": "9000-tcp",
                "port": 9000,
                "protocol": "TCP",
                "targetPort": 9000
            },
            {
                "name": "9779-tcp",
                "port": 9779,
                "protocol": "TCP",
                "targetPort": 9779
            }
        ],
        "selector": {
            "deploymentconfig": "example-spring-boot"
        },
        "sessionAffinity": "None",
        "type": "ClusterIP"
    },
    "status": {
        "loadBalancer": {}
    }
}
```

You can also use the appropriate command to view the details of a Pod:
```
$ oc get pod example-spring-boot-3-nwzku -o json
```

**Note:** First get the pod name from your project (`oc get pods`) and replace it in the upper command.

The `selector` area in the service defines which pods (`labels`) serve as endpoints. The corresponding configurations of Service and Pod can be viewed together.

Service (`oc get service <Service Name>`):
```
...
"selector": {
    "app": "example-spring-boot",
    "deploymentconfig": "example-spring-boot"
},

...
```

Pod (`oc get pod <Pod Name>`):
```
...
"labels": {
    "app": "example-spring-boot",
    "deployment": "example-spring-boot-1",
    "deploymentconfig": "example-spring-boot"
},
...
```

This link is better seen with the `oc describe` command:
```
$ oc describe service example-spring-boot
```

```
Name:      example-spring-boot
Namespace:    develop-userXY
Labels:      app=example-spring-boot
Selector:    app=example-spring-boot,deploymentconfig=example-spring-boot
Type:      ClusterIP
IP:        172.30.124.20
Port:      8080-tcp  8080/TCP
Endpoints:    10.1.3.20:8080
Session Affinity:  None
No events.
```

Under Endpoints you will now find the current Pod.


### ImageStream
[ImageStreams](https://docs.openshift.com/container-platform/4.3/openshift_images/images-understand.html) are used to perform automatic tasks such as updating a deployment when a new version of the image or base image is available.

Builds and deployments can monitor image streams and respond to changes accordingly. In our example, the image stream is used to trigger a deployment once something has changed the image.

With the following command you can get additional information about the image stream:
```
$ oc get imagestream example-spring-boot -o json
```

### Deployment & DeploymentConfig

While Deployments are preferred DeploymenConfigs have also certain specific features, that have not yet been adapted by the upstream Kubernetes Community. Read more about them [here](https://docs.openshift.com/container-platform/4.3/applications/deployments/what-deployments-are.html).

In the [DeploymentConfig](https://docs.openshift.com/container-platform/4.3/applications/deployments/what-deployments-are.html#delpoymentconfigs-specific-features_what-deployments-are) the following points are defined:

- Update Strategy: how are application updates executed, how are containers exchanged?
- Triggers: Which triggers lead to a deployment? In our example ImageChange
- container
  - What image should be deployed?
  - Environment Configuration for the Pods
  - ImagePullPolicy
- Replicas, number of pods to be deployed


The following command can be used to read additional information about DeploymentConfig:
```
$ oc get deploymentConfig example-spring-boot -o json
```

In contrast to DeploymentConfig, which tells OpenShift how an application should be deployed, the ReplicationController defines how the application should behave during runtime (e.g. that 3 replicas should always run).

**Tip:** for each resource type there is also a short form. For example, you can write `oc get deploymentconfig` as `oc get dc`.

# Make our service available online via route

In this lab we will make the application accessible from Internet via **https**.


## Routes

`oc new-app` command from the previous Lab does not create a route. So our service is not reachable from *outside* at all. If you want to make a service available, you have to set up a route for it. The OpenShift Router recognizes which service a request has to be routed to based on the host header.

Currently the following protocols are supported:

- HTTP
- HTTPS ([SNI](https://en.wikipedia.org/wiki/Server_Name_Indication))
- web sockets
- TLS with [SNI](https://en.wikipedia.org/wiki/Server_Name_Indication)

## Task

Make sure that you are in the project `develop-userXY`. **Tip:** `oc project develop-userXY`

Create a route for the `example-spring-boot` service and make it publicly available.

**Tip:** With `oc get routes` you can display the routes of a project.

```
$ oc get routes
```

Currently there is no route. Now we need the service name:

```
$ oc get services
NAME                  CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
example-spring-boot   172.30.124.20   <none>        8080/TCP   11m
```

And now we want to publish / expose this service:

```
oc create route edge --insecure-policy=Allow --service=example-spring-boot
```

By default, an http & https route is created. Can you make the Route automatically redirect to HTTPS if accessed over plain HTTP?

With `oc get routes` we can check if the route has been created.

```
$ oc get routes
NAME                  HOST/PORT                                   PATH      SERVICE                        TERMINATION   LABELS
example-spring-boot   example-spring-boot-techlab.mycluster.com             example-spring-boot:8080-tcp                 app=example-spring-boot
```

The application is now accessible from the Internet via the specified host name, so you can now access the application.

**Tip:** If no hostname is specified, the default name is used: *servicename-project.osecluster*

In the Web Console Overview, this route with the host name is now also visible.

---

# Pod Scaling, Readiness Probe and Self Healing

In this lab we show you how to scale applications in OpenShift. Furthermore, we show how OpenShift ensures that the number of expected pods is started and how an application can report back to the platform that it is ready for requests.

## Upscale Example Application

For this we use the previous project

```
$ oc project develop-userXY
```

If we want to scale our example application, we have to tell our replication controller (rc) that we always want 3 replicas of the image to work.

Let's take a closer look at the ReplicationController (rc):

```
$ oc get rc
NAME                    DESIRED   CURRENT   READY     AGE
example-spring-boot-1   1         1         1         33s
```

For more details:

```
oc get rc example-spring-boot-1 -o json
```

The rc tells us how many pods we expect (spec) and how many are currently deployed (status).

## Task: scale our example application
Now we scale our Example application to 3 replicas:

```
$ oc scale --replicas=3 dc example-spring-boot
```

Let's check the number of replicas on the ReplicationController:

```bash
$ oc get rc
NAME                    DESIRED   CURRENT   READY     AGE
example-spring-boot-4   3         3         3         16m
```

and display the pods accordingly:

```bash
$ oc get pods
NAME                          READY     STATUS    RESTARTS   AGE
example-spring-boot-4-fqh9n   1/1       Running   0          1m
example-spring-boot-4-tznqp   1/1       Running   0          16m
example-spring-boot-4-vdhqc   1/1       Running   0          1m
```

Finally, we take a look at the service. It should now reference all three endpoints:

```bash
$ oc describe svc example-spring-boot
Name:              example-spring-boot
Namespace:         develop-user
Labels:            app=example-spring-boot
                   app.kubernetes.io/component=example-spring-boot
                   app.kubernetes.io/instance=example-spring-boot
Annotations:       openshift.io/generated-by: OpenShiftNewApp
Selector:          deploymentconfig=example-spring-boot
Type:              ClusterIP
IP:                172.30.151.26
Port:              8080-tcp  8080/TCP
TargetPort:        8080/TCP
Endpoints:         10.128.16.24:8080
Port:              8778-tcp  8778/TCP
TargetPort:        8778/TCP
Endpoints:         10.128.16.24:8778
Port:              9000-tcp  9000/TCP
TargetPort:        9000/TCP
Endpoints:         10.128.16.24:9000
Port:              9779-tcp  9779/TCP
TargetPort:        9779/TCP
Endpoints:         10.128.16.24:9779
Session Affinity:  None
Events:            <none>
```

Scaling pods within a service is very fast because OpenShift simply starts a new instance of the Docker image as a container.

**Tip:** OpenShift also supports autoscaling, the documentation can be found at the following [link](https://docs.openshift.com/container-platform/4.3/nodes/pods/nodes-pods-autoscaling.html) - We will deal with this in more detail later.

## Task: scaled app in the web console

Take a look at the scaled application in the Web Console.

## Check uninterrupted scaling

With the following command you can now check if your service is available as you scale up and down.
Replace `[route]` with your defined route:

**Tip:** Command to show route (hostname): `oc get route -o custom-columns=NAME:.metadata.name,HOSTNAME:.spec.host`

```bash
while true; do sleep 1; curl -s https://[route]/pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

and scale from **3**** replicas to **1****.
The output shows the Pod that processed the request:

```bash
Pod: example-spring-boot-4-tznqp TIME: 15:07:51,162
Pod: example-spring-boot-4-vdhqc TIME: 15:07:52,516
Pod: example-spring-boot-4-fqh9n TIME: 15:07:53,904
Pod: example-spring-boot-4-tznqp TIME: 15:07:55,319
Pod: example-spring-boot-4-vdhqc TIME: 15:07:56,670
Pod: example-spring-boot-4-fqh9n TIME: 15:07:58,308
Pod: example-spring-boot-4-vdhqc TIME: 15:07:59,666
Pod: example-spring-boot-4-tznqp TIME: 15:08:01,032
Pod: example-spring-boot-4-tznqp TIME: 15:08:02,454
Pod: example-spring-boot-4-fqh9n TIME: 15:08:03,814
Pod: example-spring-boot-4-fqh9n TIME: 15:08:05,193
Pod: example-spring-boot-4-vdhqc TIME: 15:08:06,547
```

The requests will be forwarded to the different pods, as soon as you scale down to a pod, you will get only one response

What happens now when we start a new deployment while the While command is running above?

```
$ oc rollout latest example-spring-boot
```

For some time the public route gives no answer

```bash
Pod: example-spring-boot-5-rv9qs TIME: 16:13:44,938
Pod: example-spring-boot-5-rv9qs TIME: 16:13:46,258
Pod: example-spring-boot-5-rv9qs TIME: 16:13:47,567
Pod: example-spring-boot-5-rv9qs TIME: 16:13:48,875

<html>

...

  <body>
    <div>
      <h1>Application is not available</h1>

...

</html>
 TIME: 16:14:10,287
Pod: example-spring-boot-6-q99dq TIME: 16:14:11,825
Pod: example-spring-boot-6-q99dq TIME: 16:14:13,132
Pod: example-spring-boot-6-q99dq TIME: 16:14:14,428
Pod: example-spring-boot-6-q99dq TIME: 16:14:15,726
Pod: example-spring-boot-6-q99dq TIME: 16:14:17,064
Pod: example-spring-boot-6-q99dq TIME: 16:14:18,362
Pod: example-spring-boot-6-q99dq TIME: 16:14:19,655
```

It may even happen that the service is no longer online and the routing layer returns a **503 error**.

The following chapter describes how to configure your services to allow interruption-free deployments.

## Uninterrupted deployment using Readiness Probe and Rolling Update

The update strategy [Rolling](https://docs.openshift.com/container-platform/4.3/applications/deployments/deployment-strategies.html#deployments-rolling-strategy_deployment-strategies) allows interruption-free deployments. This will launch the new version of the application, as soon as the application is ready, Request will be routed to the new Pod and the old version undeployed.

In addition, the deployed application can give the platform detailed feedback about its current state via [Container Health Checks](https://docs.openshift.com/container-platform/4.3/applications/application-health.html).

Basically, there are two checks that can be implemented:

- Liveness Probe, indicates whether a running container is still running cleanly.
- Readiness Probe, gives feedback on whether an application is ready to receive requests. Is particularly relevant in the rolling update.

These two checks can be implemented as HTTP Check, Container Execution Check (Shell Script in Container) or TCP Socket Check.

In our example, the application of the platform should tell if it is ready for requests. For this we use the Readiness Probe. Our example application returns a status code 200 on the following URL on port 9000 (management port of the Spring application) as soon as the application is ready. This port is not exposed on the route. You can verify it:

```bash
oc rsh $(oc get pods -o name|grep -v deploy|awk 'NR == 1') curl http://localhost:9000/health/
```

## Task

In the Deployment Config (dc) section of the Rolling Update Strategy, define that the app should always be available during an update: `maxUnavailable: 0%`.

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

The Deployment Config can be edited via Web Console or directly via `oc`.
```
$ oc edit dc example-spring-boot
```

Or edit in JSON format:
```
$ oc edit dc example-spring-boot -o json
```

**json**

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

For the probes you need the Maintenance Port (9000).

To do this, add the port in the Deployment Config (dc) if it is not already there. This under:

spec --> template --> spec --> containers --> ports:

```yaml
...
        name: example-spring-boot
        ports:
...
        - containerPort: 9000
          protocol: TCP
...
```

Add the Readiness probe to the Deployment Config (dc):

```bash
oc set probe dc/example-spring-boot --readiness --get-url=http://:9000/health --initial-delay-seconds=10
```

The configuration under `.spec.template.spec.containers` must then look as follows:

**YAML:**

```yaml
      containers:
      - image: appuio/example-spring-boot@sha256:f5336f4bdc3037269174b93f3731698216f1cc6276ea26b0429a137e943f1413
        imagePullPolicy: Always
        name: example-spring-boot
        ports:
            -
              containerPort: 8080
              protocol: TCP
              containerPort: 9000
              protocol: TCP
          resources: {  }
          readinessProbe:
            httpGet:
              path: /health
              port: 9000
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
                        "image": "appuio/example-spring-boot@sha256:f5336f4bdc3037269174b93f3731698216f1cc6276ea26b0429a137e943f1413",
                        "imagePullPolicy": "Always",
                        "name": "example-spring-boot",
                        "ports": [
                            {
                                "containerPort": 8080,
                                "protocol": "TCP"
                            },
                            {
                                "containerPort": 9000,
                                "protocol": "TCP"
                            }
                        ],
                        "resources": {},
                        "readinessProbe": {
                            "httpGet": {
                                "path": "/health",
                                "port": 9000,
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

During the deployment of the application, verify whether the application has been updated without interruption:

One request per second:

```bash
while true; do sleep 1; curl -s http://[route]/pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

Start the deployment:

```bash
$ oc rollout latest example-spring-boot
deploymentconfig.apps.openshift.io/example-spring-boot rolled out
```

## Self Healing

Via the replication controller we have now informed the platform that **n** replicas should run in each case. What happens if we delete a Pod?

Use `oc get pods` to find a Pod with the status "running" that you can *kill*.

Start the following command in your own terminal (display changes to pods)

```
oc get pods -w
```

Delete a Pod in the other terminal with the following command

```
oc delete pod example-spring-boot-10-d8dkz
```

OpenShift makes sure that **n** replicas of the mentioned Pod run again.

In the web console you can observe how the Pod is light blue at first, until the application responds with 0K on the Readiness Probe.

# Connect database

Most applications are stateful in some way and store data persistently. Be it in a database or as files on a file system or objectstore. In this lab we will create a MySQL service in our project and connect it to our application so that several application pod can access the same database.

For this example we use the Spring Boot example `develop-userxy`. **Tip: ** `oc project develop-userxy`

## Task: Create MySQL Service

For our example we use an OpenShift template in this lab, which creates a MySQL database with EmptyDir Data Storage. This can only be used for test environments, because all data will be lost when restarting the MySQL Pod. In a later lab we will show how to add a persistent volume (mysql-persistent) to the MySQL database. This way the data remains persistent even during restarts and is therefore suitable for productive operation.

We can create the MySQL service via the Web Console as well as via the CLI.

To get the same result you only have to set database name, username, password and DatabaseServiceName to the same value, no matter which variant is used:

- MYSQL_USER techlab
- MYSQL_PASSWORD techlab
- MYSQL_DATABASE techlab
- DATABASE_SERVICE_NAME mysql

### CLI

Via the CLI the MySQL service can be created as follows with the help of a template:

```
$ oc get templates
$ oc get templates -n openshift
$ oc process --parameters mysql-persistent -n openshift
$ oc get -n openshift template mysql-persistent -o yaml > mysql-persistent.yml
$ oc process -pMYSQL_USER=techlab -pMYSQL_PASSWORD=techlab -pMYSQL_DATABASE=techlab -f mysql-persistent.yml | oc create -f -
```

### Password and username as plaintext?

When deploying the database via CLI as well as via Web Console we specified values for user, password and database via parameters. In this chapter we want to have a look where these sensitive data have effectively landed.

Let's first have a look at the DeploymentConfig of the database:

```bash
$ oc get dc mysql -o yaml
```

Specifically it is about the configuration of the containers using env (MYSQL_USER, MYSQL_PASSWORD, MYSQL_ROOT_PASSWORD, MYSQL_DATABASE) in the DeploymentConfig under `spec.template.spec.containers`:

```yaml
    spec:
      containers:
      - env:
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              key: database-user
              name: mysql
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              key: database-password
              name: mysql
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              key: database-root-password
              name: mysql
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              key: database-name
              name: mysql
```

The values for the individual environment variables thus come from a so-called secret, in our case here from the secret with the name `mysql`. In this secret the four values are stored accordingly under the appropriate keys (`database-user`, `database-password`, `database-root-password`, `database-name`) and can thus be referenced.

Let's take a look at the new resource Secret called `mysql`:

```bash
$ oc get secret mysql -o yaml
```

The corresponding key value pairs are shown under `data`:

```yaml
apiVersion: v1
data:
  database-name: dGVjaGxhYg==
  database-password: dGVjaGxhYg==
  database-root-password: SmVxR3BSZnZWNUJ3S25VUQ==
  database-user: dGVjaGxhYg==
kind: Secret
metadata:
  annotations:
    template.openshift.io/expose-database_name: '{.data[''database-name'']}'
    template.openshift.io/expose-password: '{.data[''database-password'']}'
    template.openshift.io/expose-root_password: '{.data[''database-root-password'']}'
    template.openshift.io/expose-username: '{.data[''database-user'']}'
  creationTimestamp: "2020-04-20T05:08:43Z"
  labels:
    template: mysql-persistent-template
  name: mysql
  ...
type: Opaque
```

The concrete values are base64 coded. Under Linux or in the Gitbash you can easily get the corresponding value by using :

```bash
echo "dGVjaGxhYg==" | base64 -d
techlab
```
to be displayed. In our case `dGVjaGxhYg==` is decoded in `techlab`.

With Secrets we can store sensitive information (credetials, certificates, keys, dockercfg, ...) and decouple them from the pods. At the same time we have the possibility to use the same secrets in several containers and thus avoid redundancies.

Secrets can either be mapped into environment variables, as in the MySQL database above, or mounted directly into a container as files via volumes.

More information about Secrets can be found in the [official documentation](https://docs.openshift.com/container-platform/4.3/nodes/pods/nodes-pods-secrets.html).

## Task: Connect application to database

By default our example-spring-boot application uses a H2 memory database. This can be changed to our new MySQL service by setting the following environment variables:

- SPRING_DATASOURCE_USERNAME techlab
- SPRING_DATASOURCE_PASSWORD techlab
- SPRING_DATASOURCE_DRIVER_CLASS_NAME com.mysql.jdbc.Driver
- SPRING_DATASOURCE_URL jdbc:mysql://[MySQL service address]/techlab?autoReconnect=true

For the MySQL service address we can use either its cluster IP (`oc get service`) or its DNS name (`<service>`). All services and pods within a project can be resolved via DNS.

This is the value for the variable SPRING_DATASOURCE_URL for example:
```
Name of the service: mysql

jdbc:mysql://mysql/techlab?autoReconnect=true
```

We can now set these environment variables in the DeploymentConfig example-spring-boot. After **ConfigChange** (ConfigChange is registered as a trigger in DeploymentConfig) the application is automatically deployed again. Due to the new environment variables the application connects to the MySQL DB and [Liquibase](http://www.liquibase.org/) creates the schema and imports the test data.

**Note:** Liquibase is Open Source. It is a database independent library to manage database changes and apply them to the database. Liquibase recognizes at the startup of the application whether DB changes have to be applied to the database or not. See Logs.


```
SPRING_DATASOURCE_URL=jdbc:mysql://mysql/techlab?autoReconnect=true
```

**Note:** mysql resolves within your project via DNS query to the cluster IP of the MySQL service. The MySQL database is only accessible within the project. The service is also accessible via the following name:

```
Project name = techlab-dockerimage

mysql.techlab-dockerimage.svc.cluster.local
```

Command for setting the environment variables:

```bash
oc set env dc example-spring-boot \
      -e SPRING_DATASOURCE_URL="jdbc:mysql://mysql/techlab?autoReconnect=true" \
      -e SPRING_DATASOURCE_USERNAME=techlab \
      -e SPRING_DATASOURCE_PASSWORD=techlab \
      -e SPRING_DATASOURCE_DRIVER_CLASS_NAME=com.mysql.jdbc.Driver
```

You can use the following command to view DeploymentConfig as JSON. The Config now also contains the set environment variables:

```bash
 oc get dc example-spring-boot -o json
```

```json
...
 "env": [
          {
              "name": "SPRING_DATASOURCE_USERNAME",
              "value": "techlab"
          },
          {
              "name": "SPRING_DATASOURCE_PASSWORD",
              "value": "techlab"
          },
          {
              "name": "SPRING_DATASOURCE_DRIVER_CLASS_NAME",
              "value": "com.mysql.jdbc.Driver"
          },
          {
              "name": "SPRING_DATASOURCE_URL",
              "value": "jdbc:mysql://mysql/techlab?autoReconnect=true"
          }
      ],
...
```

The configuration can also be viewed and changed in the Web Console:

(Applications → Deployments → example-spring-boot, Actions, Edit YAML)

## Task: Reference Secret

Above we have seen how OpenShift decouples sensitive information from the actual configuration using Secrets and helps us to avoid redundancies. We configured our Springboot application from the previous lab correctly, but stored the values redundant and plaintext in DeploymentConfig.

Now let's adjust the DeploymentConfig example-spring-boot so that the values from the Secrets are used. Note the configuration of the containers under `spec.template.spec.containers`.

Using `oc edit dc example-spring-boot -o json` you can edit the DeploymentConfig as Json as follows.

```json
...
"env": [
    {
        "name": "SPRING_DATASOURCE_USERNAME",
        "valueFrom": {
            "secretKeyRef": {
                "key": "database-user",
                "name": "mysql"
            }
        }
    },
    {
        "name": "SPRING_DATASOURCE_PASSWORD",
        "valueFrom": {
            "secretKeyRef": {
                "key": "database-password",
                "name": "mysql"
            }
        }
    },
    {
        "name": "SPRING_DATASOURCE_DRIVER_CLASS_NAME",
        "value": "com.mysql.jdbc.Driver"
    },
    {
        "name": "SPRING_DATASOURCE_URL",
        "value": "jdbc:mysql://mysql/techlab"
    }
],

...
```

Now the values for username and password for both mysql Pod and Springboot Pod are read from the same secret.


## Task: Log in to MySQL Service Pod and connect manually to DB

It can be logged into a Pod using `oc rsh [POD]`:

```bash
$ oc get pods
NAME READY STATUS STARTS NEW OLD
example-spring-boot-8-wkros 1/1 running 0 10m
mysql-1-diccy 1/1 Running 0 50m

```

Then log in to the MySQL Pod:

```bash
oc rsh mysql-1-diccy
```

It is easier to reference the pod using the DeploymentConfig:

```bash
oc rsh dc/mysql
```

Now you can use mysql tool to connect to the database and display the tables:

```bash
$ mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_SERVICE_HOST techlab
Willkommen beim MySQL-Monitor.  Befehle enden mit ; oder \g.
Deine MySQL-Verbindungs-ID ist 54.
Server-Version: 5.6.26 MySQL Community Server (GPL)

Copyright (c) 2000, 2015, Oracle und/oder seine verbundenen Unternehmen. Alle Rechte vorbehalten.

Oracle ist eine eingetragene Marke der Oracle Corporation und/oder ihrer Tochtergesellschaften.
verbundene Unternehmen. Andere Namen können Marken der jeweiligen Unternehmen sein.
Besitzer.

Tippen Sie "help;" oder "\h" für Hilfe. Geben Sie'\c' ein, um die aktuelle Eingabeaufforderung zu löschen.

mysql>
```

Afterwards you can with the following command:

```bash
show tables;
```

Display all tables.


## Task: Import dump to MySQL DB

The task is to import the [Dump](../labs/data/08_dump/dump.sql) into the MySQL Pod.


**Tip:** Use `oc rsync` to copy local files to a Pod. Alternatively you can use curl in the mysql container.

**Note:** Note that this uses the rsync command of the operating system. On UNIX systems rsync can be installed with the package manager, on Windows for example [cwRsync](https://www.itefix.net/cwrsync) can be installed. If an installation of rsync is not possible, you can log into the Pod instead and download the dump via `curl -O <URL>`.

**Tip:** Use the mysql tool to install the dump.

**Tip:** The existing database must be empty. It can also be deleted and recreated.


---

## Solution

Sync an entire directory (dump). It contains the file `dump.sql`. For the rsync command, also note the above tip and the missing trailing slash.

```bash
oc rsync ./labs/data/08_dump mysql-1-diccy:/tmp/
```

Log in to the MySQL Pod:

```bash
oc rsh dc/mysql
```

Delete existing database:

```bash
$ mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_SERVICE_HOST techlab
...
mysql> drop database techlab;
mysql> create database techlab;
mysql> exit
```

Dump in:

```bash
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_SERVICE_HOST techlab < /tmp/08_dump/dump.sql
```

**Note:** The dump can be created as follows:

```bash
mysqldump --user=$MYSQL_USER --password=$MYSQL_PASSWORD --host=$MYSQL_SERVICE_HOST techlab > /tmp/dump.sql
```

# Bonus - Integration Webhook

The initial ruby-ex application is also hosted in gitlab. Make a fork of the application and integrate the webhook of the build into the project.

If you now make changes to the code, a build will be started and the new version will be available.
