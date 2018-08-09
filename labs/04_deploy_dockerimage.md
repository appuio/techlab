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

Mit dem entsprechenden Befehl können Sie auch die Details zu einem Pod anzeigen:
```
$ oc get pod example-spring-boot-3-nwzku -o json
```

**Note:** Zuerst den pod Namen aus Ihrem Projekt abfragen (`oc get pods`) und im oberen Befehl ersetzen.

Über den `selector` Bereich im Service wird definiert, welche Pods (`labels`) als Endpoints dienen. Dazu die entsprechenden Konfigurationen vom Service und Pod zusammen betrachten.
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

Diese Verknüpfung ist mittels dem `oc describe` Befehl zu sehen:
```
$ oc describe service example-spring-boot
```

```
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

Unter Endpoints finden Sie nun den aktuell laufenden Pod.


### ImageStream
[ImageStreams](https://docs.openshift.com/container-platform/3.5/architecture/core_concepts/builds_and_image_streams.html#image-streams) werden dafür verwendet, automatische Tasks auszuführen wie bspw. ein Deployment zu aktualisieren, wenn eine neue Version des Images oder des Basisimages verfügbar ist.

Builds und Deployments können Image Streams beobachten und auf Änderungen entsprechend reagieren. In unserem Beispiel wird der Image Stream dafür verwendet, ein Deployment zu triggern, sobald etwas am Image geändert hat.

Mit dem folgenden Befehl können Sie zusätzliche Informationen über den Image Stream auslesen:
```
$ oc get imagestream example-spring-boot -o json
```

### DeploymentConfig

In der [DeploymentConfig](https://docs.openshift.com/container-platform/3.5/dev_guide/deployments/how_deployments_work.html) werden folgende Punkte definiert:

- Update Strategy: wie werden Applikationsupdates ausgeführt, wie erfolgt das Austauschen der Container?
- Triggers: Welche Triggers führen zu einem Deployment? In unserem Beispiel ImageChange
- Container
  - Welches Image soll deployed werden?
  - Environment Configuration für die Pods
  - ImagePullPolicy
- Replicas, Anzahl der Pods, die deployt werden sollen


Mit dem folgenden Befehl können zusätzliche Informationen zur DeploymentConfig ausgelesen werden:
```
$ oc get deploymentConfig example-spring-boot -o json
```

Im Gegensatz zur DeploymentConfig, mit welcher man OpenShift sagt, wie eine Applikation deployt werden soll, definiert man mit dem ReplicationController, wie die Applikation während der Laufzeit aussehen soll (bspw. dass immer 3 Replicas laufen sollen).

**Hint:** für jeden Resource Type gibt es auch eine Kurzform. So können Sie bspw. `oc get deploymentconfig` auch einfach als `oc get dc` schreiben.

---

## ZusatzTask für Schnelle ;-)

Schauen Sie sich die erstellten Ressourcen mit `oc get [ResourceType] [Name] -o json` und `oc describe [ResourceType] [Name]` aus dem ersten Projekt `[USER]-example1` an.

---

**Ende Lab 4**

<p width="100px" align="right"><a href="05_create_route.md">Routen erstellen →</a></p>

[← back to overview](../README.md)
