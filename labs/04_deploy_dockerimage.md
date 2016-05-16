# Lab 4: Ein Docker Image deployen

In diesem Lab werden wir gemeinsam das erste "pre-built" Docker image deployen und die OpenShift Konzpte Pod, Service, DeploymentConfig und Imagestream etwas genauer anschauen.


## Aufgabe: LAB4.1

Nach dem wir im [Lab 3](labs/03_first_steps.md) den Source To Image Workflow verwendet haben um eine Applikation auf OpenShift zu deployen, wenden wir uns nun dem deployen eines pre-build Docker images von Dockerhub oder einer anderen Dockerregistry zu.

> [Weiterführrende Dokumentation](https://docs.openshift.com/enterprise/3.1/dev_guide/new_app.html#specifying-an-image)

Als ersten Schritt erstellen wir dafür ein neues Projekt. Ein Projekt ist eine Gruppierung von Resourcen, in welchem berechtigte User (Container und Docker Images, Pods, Services, Routen, Konfiguration, Quotas und Limiten ...) verwalten können. Innerhalb eines OpenShift V3 Clusters muss der Name eines Projektes eindeutig sein.

Erstellen Sie daher ein neues Projekt mit dem Namen: `[USER]-dockerimage`

```
$ oc new-project [USER]-dockerimage
```

`oc new-project` wechselt automatisch in das eben neu angelegte Projekt. Mit dem `oc get` command können Resourcen von einem bestimmten Typ angezeigt werden. 

Verwenden Sie
```
$ oc get project
```
um alle Projekte, auf denen Sie berechtigt sind, anzuzeigen.

Sobald das neue Projekt erstellt wurden, sagen wir OpenShift mit dem folgenden Befehl, das Docker Image soll deployed werden:

```
$ oc new-app appuio/example-spring-boot
```
Output:
```
--> Found Docker image 7823c6b (58 minutes old) from Docker Hub for "appuio/example-spring-boot"
    * An image stream will be created as "example-spring-boot:latest" that will track this image
    * This image will be deployed in deployment config "example-spring-boot"
    * Port 8080/tcp will be load balanced by service "example-spring-boot"
--> Creating resources with label app=example-spring-boot ...
    ImageStream "example-spring-boot" created
    DeploymentConfig "example-spring-boot" created
    Service "example-spring-boot" created
--> Success
    Run 'oc status' to view your app.
```

Für unser Lab verwenden wir ein APPUiO Beispiel (Java Spring Boot Applikation):
- DockerHub: https://hub.docker.com/r/appuio/example-spring-boot/
- GitHub (Source): https://github.com/appuio/example-spring-boot-helloworld

OpenShift legt die nötigen Resourcen an, lädt das Docker Image in diesem Fall von Docker Hub herunter und deployed anschliessend den ensprechenden Pod

**Tipp:** Verwenden Sie `oc status` um sich einen Überblick über das Projekt zu verschaffen.

Oder vewerden Sie den `oc get` Command um Änderungen an den Resourcen des Typs Pods anzuzeigen
```
$ oc get pods -w
```

Je nach Internet Verbindung oder ob das Image auf Ihrem OpenShift Node bereits heruntergeladen wurde, kann das eine Weile dauern. Schauen Sie sich doch in der Web Console den aktuellen Status des Deployments an:

1. In der Web Console einloggen
2. Wählen Sie Ihr Projekt aus `[USER]-dockerimage`
3. Klickes Sie auf Browse
4. Wählen Sie Pods aus


**Tipp** Um Ihre eigenen Docker Images für OpenShift zu erstellen, sollten Sie die folgenden Best Practices befolgen: https://docs.openshift.com/enterprise/3.1/creating_images/guidelines.html


## Nun schauen wir uns die erstellten Resourcen etwas genauer an.

Als wir `oc new-app appuio/example-spring-boot` vorhin ausgeführt haben, hat OpenShift im Hintergrund einige Resourcen für uns angelegt, die dafür benötigt werden, dieses Docker Image zu deployen:

- [Service](https://docs.openshift.com/enterprise/3.1/architecture/core_concepts/pods_and_services.html#services)
- [ImageStream](https://docs.openshift.com/enterprise/3.1/architecture/core_concepts/builds_and_image_streams.html#image-streams)
- [DeploymentContig](https://docs.openshift.com/enterprise/3.1/dev_guide/deployments.html)

### Service

[Service](https://docs.openshift.com/enterprise/3.1/architecture/core_concepts/pods_and_services.html#services) dienen innerhalb OpenShift als Abstraktionslayer, Einstiegspunkt und Proxy/Loadbalancer auf die dahinterliegenden Pods. Der Service ermöglicht es innerhalb OpenShift eine Gruppe von Pods des gleichen Typs zu finden und anzusprechen.

Als Beispiel: Wenn eine Applikationsinstanz unseres Beispiels die Last nicht mehr alleine verarbeiten kann, können wir die Applikation auf bspw. drei Pods hochskalieren. OpenShift mapt dieses als Endpoints automatisch zum Service. Sobald die Pods bereit sind, werden Requests dann automatisch auf alle drei Pods geleitet. 

**Note:** Die Applikation kann aktuell von aussenher noch nicht erreicht werden, der Service ist ein OpenShift internes Konzept. Im folgenden Lab werden wir die Applikation öffentlich verfügbar machen

Nun schauen wir uns unseren Service mal etwas genauer an:

```
$ oc get services
```

```
NAME                    CLUSTER_IP       EXTERNAL_IP   PORT(S)    SELECTOR                                                           AGE
example-spring-boot     172.30.96.92     <none>        8080/TCP   app=example-spring-boot,deploymentconfig=example-spring-boot       2h
```

Wie Sie am Output sehen, ist unser Service (example-spring-boot) über eine IP und Port erreichbar (172.30.96.92:8080) **Note:** Ihre IP kann unterschiedlich sein.

**Note:** Service IPs bleiben während ihrer Lebensdauer immer gleich.

Mit dem folgenden Befehl können zusätzliche Informationen über den Service auslesen:
```
$ oc get service example-spring-boot -o json
```

```
{
    "kind": "Service",
    "apiVersion": "v1",
    "metadata": {
        "name": "example-spring-boot",
        "namespace": "techlab",
        "selfLink": "/api/v1/namespaces/techlab/services/example-spring-boot",
        "uid": "d4277ccc-1b40-11e6-a1ae-001a4a026f33",
        "resourceVersion": "2291956",
        "creationTimestamp": "2016-05-16T08:33:13Z",
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
        "portalIP": "172.30.96.92",
        "clusterIP": "172.30.96.92",
        "type": "ClusterIP",
        "sessionAffinity": "None"
    },
    "status": {
        "loadBalancer": {}
    }
}
```

Mit dem selben Befehlt können Sie auch die Details zu einem Pod anziegen:
```
$ oc get pod example-spring-boot-3-nwzku -o json
```

Über den `selector` Bereich im Service wird definiert, welche Pods (`labels`) als Endpoints dienen.
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
    "deployment": "example-spring-boot-3",
    "deploymentconfig": "example-spring-boot"
},
...

```

Diese Verknüpfung ist mittels dem `oc describe` Befehl zu sehen:
```
$ oc describe service example-spring-boot
```

```
Name:                   example-spring-boot
Namespace:              techlab
Labels:                 app=example-spring-boot
Selector:               app=example-spring-boot,deploymentconfig=example-spring-boot
Type:                   ClusterIP
IP:                     172.30.96.92
Port:                   8080-tcp        8080/TCP
Endpoints:              10.255.1.154:8080
Session Affinity:       None
No events.
```

Unter Endpoints finden Sie nun den aktuell laufenden Pod


### ImageStream
[ImageStreams](https://docs.openshift.com/enterprise/3.1/architecture/core_concepts/builds_and_image_streams.html#image-streams) werden dafür verwendet um automatische tasks, wie ein Deployment aktualisieren, wenn eine neue Version des Images oder Basisimage verfügbar ist.

Builds und Deployments können image Streams beobachten und auf Änderungen entsprechend reagieren. In unserem Beispiel wird der Image Stream dafür verwendet, ein Deployment zu triggern sobald etwas am Image geändert hat.

Mit dem folgenden Befehl können zusätzliche Informationen über den ImageStream auslesen:
```
$ oc get imageStream example-spring-boot -o json
```

### DeploymentContfig

In der [DeploymentContig](https://docs.openshift.com/enterprise/3.1/dev_guide/deployments.html) werden folgende Punkte definiert:

- Update Strategy: wie werden Applikationsupdates ausgeführt, wie erfolgt das Austauschen der Container
- Triggers: Welche Triggers führen zu einem Deployment? in unserem Beispiel ImageChange
- Container
-- Welches Image soll deployed werden
-- Environment Configuration für die Pods
-- ImagePullPolicy
- Replicas, Anzahl der Pods die deployed werden sollen.


Mit dem folgenden Befehl können zusätzliche Informationen über den DeploymentConfig auslesen:
```
$ oc get deploymentConfig example-spring-boot -o json
```

**Tipp:** für jeden Resource Type gibt es auch einen Kurform, so können sie beispielweise `oc get deploymentConfig` auch einfach als `oc get dc` schreiben.

---

## Zusatzaufgabe für Schnelle ;-)

Schauen Sie sich die erstellten Resourcen mit `oc get [ResourceTyp] [Name] -o json` und `oc describe [ResourceTyp] [Name]` aus dem ersten Projekt `[USER]-example1` an.

---

**Ende Lab 4**

[<< zurück zur Übersicht] (../README.md)






