# Lab 4: Deploy a Docker Image

In this lab, we will jointly deploy the first "pre-built" Docker image and take a closer look at the OpenShift concepts Pod, Service, DeploymentConfig and ImageStream.

## Task: LAB4.1

After deploying with the Source-to-Image workfrow in [Lab 3](03_first_steps.md) we now turn towards deploying a pre-built Docker Image from Docker Hub or another Docker-Registry.

> [Further Documentation](https://docs.openshift.com/container-platform/3.5/dev_guide/application_lifecycle/new_app.html#specifying-an-image)

In a first step we create a new project. A project is a grouping of resources (containers and docker images, pods, services, routes, configurations, quotas, limits and more).Authorized Users for this Project can manage these ressources. Within an OpenShift V3 cluster the name of a project must be unique.

Therefore create a new project called `[USER]-dockerimage`:

```bash
$ oc new-project [USER]-dockerimage
```

`oc new-project` switches automatically into the new Project. The `oc get` Command shows ressources of a particular type.

eg.
```
$ oc get project
```
to show all projects the current user is authorized to see.

Once you crated the new project you can deploy the Docker Image in Openshift using:

```bash
$ oc new-app appuio/example-spring-boot
--> Found Docker image d790313 (3 weeks old) from Docker Hub for "appuio/example-spring-boot"

    APPUiO Spring Boot App
    ----------------------
    Example Spring Boot App

    Tags: builder, springboot

    * An image stream will be created as "example-spring-boot:latest" that will track this image
    * This image will be deployed in deployment config "example-spring-boot"
    * Port 8080/tcp will be load balanced by service "example-spring-boot"
      * Other containers can access this service through the hostname "example-spring-boot"

--> Creating resources with label app=example-spring-boot ...
    imagestream "example-spring-boot" created
    deploymentconfig "example-spring-boot" created
    service "example-spring-boot" created
--> Success
    Run 'oc status' to view your app.

```

For our Lab we use an APPUiO-Example (Java Spring Boot Application):
- Docker Hub: https://hub.docker.com/r/appuio/example-spring-boot/
- GitHub (Source): https://github.com/appuio/example-spring-boot-helloworld

OpenShift creates the necessary resources, downloads the Docker Image (in this case from Docker Hub) and deploys the Pod.

**Hint:** Use `oc status` to get an overview of the project.

Or use the `oc get` Command with `-w` parameter, to get changes displayed continuous. (abort with ctrl+c):
```
$ oc get pods -w
```

Depending on your internet connection and wheter the image was allready downloaded to the node this can take a while. Check the current status of your deployment in the Web Console:

1. Loggen in to the Web Console
2. Select your project `[USER]-dockerimage`
3. Click Applications
4. Select Pods


**Hint** To Create your own Docker Image to run on Openshift, you should follow these best Practices: https://docs.openshift.com/container-platform/3.5/creating_images/guidelines.html

## Examine the created resources
When we first executed `oc new-app appuio/example-spring-boot` OpenShift created some resources for us in the background. These are required to deploy this docker image:

- [Service](https://docs.openshift.com/container-platform/3.5/architecture/core_concepts/pods_and_services.html#services)
- [ImageStream](https://docs.openshift.com/container-platform/3.5/architecture/core_concepts/builds_and_image_streams.html#image-streams)
- [DeploymentConfig](https://docs.openshift.com/container-platform/3.5/dev_guide/deployments/how_deployments_work.html)

### Service

[Services](https://docs.openshift.com/container-platform/3.5/architecture/core_concepts/pods_and_services.html#services) serve as an abstraction layer, entry point and Proxy/Loadbalancer to the Pods. The Service allows OpenShift to find and approach a group of pods.

As an example, if an application can't carry the load alone we can scale it to more pods. Openshift automaticaly maps those endpoints to the service and as soon as the pods are ready the requests are balanced to all the running pods.

**Note:** At the moment, our application isn't available from the outside. A service is a OpenShift internal concept. We will achive this in the next lab.

But first, let us take a closer look at the service:

```bash
$ oc get services
NAME                  CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
example-spring-boot   172.30.124.20   <none>        8080/TCP   2m
```

As you can see on the output, our service (example-spring-boot) is accessible via an IP and port (172.30.124.20:8080) **Note**: Your IP may be different.

**Note:** Service IPs remain the same for their lifetime.

Use the following command to read additional information about the service:

```bash
$ oc get service example-spring-boot -o json
{
    "kind": "Service",
    "apiVersion": "v1",
    "metadata": {
        "name": "example-spring-boot",
        "namespace": "techlab",
        "selfLink": "/api/v1/namespaces/techlab/services/example-spring-boot",
        "uid": "b32d0197-347e-11e6-a2cd-525400f6ccbc",
        "resourceVersion": "17247237",
        "creationTimestamp": "2016-06-17T11:29:05Z",
        "labels": {
            "app": "example-spring-boot"
        },
        "annotations": {
            "openshift.io/generated-by": "OpenShiftNewApp"
        }
    },
    "spec": {
        "ports": [
            {
                "name": "8080-tcp",
                "protocol": "TCP",
                "port": 8080,
                "targetPort": 8080
            }
        ],
        "selector": {
            "app": "example-spring-boot",
            "deploymentconfig": "example-spring-boot"
        },
        "portalIP": "172.30.124.20",
        "clusterIP": "172.30.124.20",
        "type": "ClusterIP",
        "sessionAffinity": "None"
    },
    "status": {
        "loadBalancer": {}
    }
}
```

Accordingly you can get detials to a pod:

```
$ oc get pod example-spring-boot-3-nwzku -o json
```

**Note:** First get the name of the pod (`oc get pods`) and then use it for the above command.

Trough the `selector` area in a service you'll see wich Pods (`labels`) serve as an endpoint. To do so, consider the corresponding configurations of the service and pod together.

```
Service:
--------
...
"selector": {
    "app": "example-spring-boot",
    "deploymentconfig": "example-spring-boot"
},

...

Pod:
----
...
"labels": {
    "app": "example-spring-boot",
    "deployment": "example-spring-boot-1",
    "deploymentconfig": "example-spring-boot"
},
...

```

This link can be viewed using the `oc describe` command:
```bash
$ oc describe service example-spring-boot
Name:			example-spring-boot
Namespace:		techlab
Labels:			app=example-spring-boot
Selector:		app=example-spring-boot,deploymentconfig=example-spring-boot
Type:			ClusterIP
IP:				172.30.124.20
Port:			8080-tcp	8080/TCP
Endpoints:		10.1.3.20:8080
Session Affinity:	None
No events.
```

Under Endpoints, you will now find the currently running pod.


### ImageStream
[ImageStreams](https://docs.openshift.com/container-platform/3.5/architecture/core_concepts/builds_and_image_streams.html#image-streams) are used to perform automatic tasks such as updating a deployment when a new Version of the image or base image is available.

Builds and deployments can monitor image streams and respond to changes appropriately. In our example, the ImageStream is used to trigger a deployment when something changes to the image.

Use the following command to read additional information about the Image Stream:
```
$ oc get imagestream example-spring-boot -o json
```

### DeploymentConfig

The following points are defined in [DeploymentConfig](https://docs.openshift.com/container-platform/3.5/dev_guide/deployments/how_deployments_work.html):

- Update Strategy: How are application updates executed, how is the container replaced?
- Triggers: Which triggers lead to a deployment? In our example, ImageChange
- Container
  - Which image should be deployed?
  - Environment Configuration for the pods
  - ImagePullPolicy
- Replicas, number of pods to be deployed

The following command can be used to read additional information about DeploymentConfig:
```
$ oc get deploymentConfig example-spring-boot -o json
```

In contrast to DeploymentConfig, which tells OpenShift how an application is to be deployed, the ReplicationController defines how the application should look during the runtime (for example, 3 replicas should always run).

**Hint:** for each resource type, there is also a short form. For example, you can simply write `oc get deploymentconfig` as `oc get dc`.

---

## Additional tasks for the fast ones ;-)

Look at the created resources with  `oc get [ResourceType] [Name] -o json` and `oc describe [ResourceType] [Name]` from the first project `[USER]-example1`.

---

**End Lab 4**

<p width="100px" align="right"><a href="05_create_route.md">create routes →</a></p>

[← back to overview](../README.md)