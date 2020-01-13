# Lab 4: Ein Container Image deployen

In diesem Lab werden wir gemeinsam das erste "pre-built" Container Image deployen und die OpenShift-Konzepte Pod, Service, DeploymentConfig und ImageStream etwas genauer anschauen.

## Aufgabe: LAB4.1

Nachdem wir im [Lab 3](03_first_steps.md) den Source-to-Image Workflow verwendet haben, um eine Applikation auf OpenShift zu deployen, wenden wir uns nun dem Deployment eines pre-built Container Image von Docker Hub (oder einer anderen Image Registry) zu.

Als ersten Schritt erstellen wir dafür ein neues Projekt. Ein Projekt ist eine Gruppierung von Ressourcen (Container und Container Images, Pods, Services, Routen, Konfiguration, Quotas, Limiten und weiteres). Für das Projekt berechtigte User können diese Ressourcen verwalten. Innerhalb eines OpenShift Clusters muss der Name eines Projektes eindeutig sein.

Erstellen Sie daher ein neues Projekt mit dem Namen `[USER]-dockerimage`:

<details><summary>Tipp</summary>oc new-project [USER]-dockerimage</details><br/>

`oc new-project` wechselt automatisch in das eben neu angelegte Projekt. Mit dem `oc get` Command können Ressourcen von einem bestimmten Typ angezeigt werden.

Verwenden Sie

```bash
oc get project
```

um alle Projekte anzuzeigen, auf die Sie berechtigt sind.

Sobald das neue Projekt erstellt wurde, können wir in OpenShift mit dem folgenden Befehl das Container Image deployen:

```bash
oc new-app appuio/example-spring-boot
```

Befehl mit Output:

```bash
$ oc new-app appuio/example-spring-boot
--> Found Docker image dc47fe9 (4 minutes old) from Docker Hub for "appuio/example-spring-boot"

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

Für unser Lab verwenden wir ein APPUiO-Beispiel (Java Spring Boot Applikation):

- Docker Hub: <https://hub.docker.com/r/appuio/example-spring-boot/>
- GitHub (Source): <https://github.com/appuio/example-spring-boot-helloworld>

OpenShift legt die nötigen Ressourcen an, lädt das Container Image, in diesem Fall von Docker Hub, herunter und deployt anschliessend den Pod.

**Tipp:** Verwenden Sie `oc status` um sich einen Überblick über das Projekt zu verschaffen.

Oder verwenden Sie den `oc get` Befehl mit dem `-w` Parameter, um fortlaufend Änderungen an den Ressourcen des Typs Pod anzuzeigen (abbrechen mit ctrl+c):

```bash
oc get pods -w
```

Je nach Internetverbindung oder abhängig davon, ob das Image auf Ihrem OpenShift Node bereits heruntergeladen wurde, kann das eine Weile dauern. In der Zwischenzeit können Sie sich in der Web Console den aktuellen Status des Deployments anschauen:

1. Loggen Sie sich in der Web Console ein
2. Wählen Sie Ihr Projekt `[USER]-dockerimage` aus
3. Klicken Sie auf Applications
4. Wählen Sie Pods aus

**Tipp** Um Ihre eigenen Container Images für OpenShift zu erstellen, sollten Sie die folgenden Best Practices befolgen: https://docs.openshift.com/container-platform/3.11/creating_images/guidelines.html

## Betrachten der erstellten Ressourcen

Als wir `oc new-app appuio/example-spring-boot` vorhin ausführten, hat OpenShift im Hintergrund einige Ressourcen für uns angelegt. Diese werden dafür benötigt, das Container Image zu deployen:

- [Service](https://docs.openshift.com/container-platform/3.11/architecture/core_concepts/pods_and_services.html#services)
- [ImageStream](https://docs.openshift.com/container-platform/3.11/architecture/core_concepts/builds_and_image_streams.html#image-streams)
- [DeploymentConfig](https://docs.openshift.com/container-platform/3.11/dev_guide/deployments/how_deployments_work.html)

### Service

[Services](https://docs.openshift.com/container-platform/3.11/architecture/core_concepts/pods_and_services.html#services) dienen innerhalb OpenShift als Abstraktionslayer, Einstiegspunkt und Proxy/Loadbalancer auf die dahinterliegenden Pods. Der Service ermöglicht es, innerhalb OpenShift eine Gruppe von Pods des gleichen Typs zu finden und anzusprechen.

Als Beispiel: Wenn eine Applikationsinstanz unseres Beispiels die Last nicht mehr alleine verarbeiten kann, können wir die Applikation bspw. auf drei Pods hochskalieren. OpenShift mapt diese als Endpoints automatisch zum Service. Sobald die Pods bereit sind, werden Requests automatisch auf alle drei Pods verteilt.

**Note:** Die Applikation kann aktuell von aussen noch nicht erreicht werden, der Service ist ein OpenShift-internes Konzept. Im folgenden Lab werden wir die Applikation öffentlich verfügbar machen.

Nun schauen wir uns unseren Service mal etwas genauer an:

```bash
$ oc get services
NAME                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
example-spring-boot   ClusterIP   172.30.141.7   <none>        8080/TCP,8778/TCP,9779/TCP   3m
```

Wie Sie am Output sehen, ist unser Service (example-spring-boot) über eine IP und mehrere Ports erreichbar (z.B. 172.30.141.7:8080)

**Note:** Ihre IP wird mit grosser Wahrscheinlichkeit von der hier gezeigten abweichen.

**Note:** Service IPs bleiben während ihrer Lebensdauer immer gleich.

Mit dem folgenden Befehl können Sie zusätzliche Informationen über den Service auslesen:

```bash
$ oc get service example-spring-boot -o json
{
    "apiVersion": "v1",
    "kind": "Service",
    "metadata": {
        "annotations": {
            "openshift.io/generated-by": "OpenShiftNewApp"
        },
        "creationTimestamp": "2020-01-09T08:21:13Z",
        "labels": {
            "app": "example-spring-boot"
        },
        "name": "example-spring-boot",
        "namespace": "techlab",
        "resourceVersion": "39162349",
        "selfLink": "/api/v1/namespaces/techlab/services/example-spring-boot",
        "uid": "ff9bc391-32b8-11ea-b825-fa163e286250"
    },
    "spec": {
        "clusterIP": "172.30.9.146",
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
            "app": "example-spring-boot",
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

**Tipp:** Der `-o` Parameter akzeptiert auch `yaml` als Angabe.

Mit dem entsprechenden Befehl können Sie auch die Details zu einem Pod anzeigen:

```bash
oc get pod example-spring-boot-3-nwzku -o json
```

**Note:** Zuerst den Pod Namen aus Ihrem Projekt abfragen (`oc get pods`) und im oberen Befehl ersetzen.

Über den `selector` Bereich im Service wird definiert, welche Pods (`labels`) als Endpoints dienen. Dazu können die entsprechenden Konfigurationen von Service und Pod zusammen betrachtet werden.

Service (`oc get service <Service Name>`):

```json
...
"selector": {
    "app": "example-spring-boot",
    "deploymentconfig": "example-spring-boot"
},

...
```

Pod (`oc get pod <Pod Name>`):

```json
...
"labels": {
    "app": "example-spring-boot",
    "deployment": "example-spring-boot-1",
    "deploymentconfig": "example-spring-boot"
},
...
```

Diese Verknüpfung ist besser mittels `oc describe` Befehl zu sehen:

```bash
$ oc describe service example-spring-boot
Name:              example-spring-boot
Namespace:         techlab
Labels:            app=example-spring-boot
Annotations:       openshift.io/generated-by=OpenShiftNewApp
Selector:          app=example-spring-boot,deploymentconfig=example-spring-boot
Type:              ClusterIP
IP:                172.30.9.146
Port:              8080-tcp  8080/TCP
TargetPort:        8080/TCP
Endpoints:         10.128.2.203:8080
Port:              8778-tcp  8778/TCP
TargetPort:        8778/TCP
Endpoints:         10.128.2.203:8778
Port:              9000-tcp  9000/TCP
TargetPort:        9000/TCP
Endpoints:         10.128.2.203:9000
Port:              9779-tcp  9779/TCP
TargetPort:        9779/TCP
Endpoints:         10.128.2.203:9779
Session Affinity:  None
Events:            <none>
```

Unter Endpoints finden Sie nun den aktuell laufenden Pod.

### ImageStream

[ImageStreams](https://docs.openshift.com/container-platform/3.11/architecture/core_concepts/builds_and_image_streams.html#image-streams) werden dafür verwendet, automatische Tasks auszuführen wie bspw. ein Deployment zu aktualisieren, wenn eine neue Version des Images oder des Basisimages verfügbar ist.

Builds und Deployments können Image Streams beobachten und auf Änderungen entsprechend reagieren. In unserem Beispiel wird der Image Stream dafür verwendet, ein Deployment zu triggern, sobald etwas am Image geändert hat.

Mit dem folgenden Befehl können Sie zusätzliche Informationen über den Image Stream auslesen:

```bash
oc get imagestream example-spring-boot -o json
```

### DeploymentConfig

In der [DeploymentConfig](https://docs.openshift.com/container-platform/3.11/dev_guide/deployments/how_deployments_work.html) werden folgende Punkte definiert:

- Update Strategy: wie werden Applikationsupdates ausgeführt, wie erfolgt das Austauschen der Container?
- Triggers: Welche Triggers führen zu einem Deployment? In unserem Beispiel ImageChange
- Container
  - Welches Image soll deployed werden?
  - Environment Configuration für die Pods
  - ImagePullPolicy
- Replicas, Anzahl der Pods, die deployt werden sollen

Mit dem folgenden Befehl können zusätzliche Informationen zur DeploymentConfig ausgelesen werden:

```bash
oc get deploymentConfig example-spring-boot -o json
```

Im Gegensatz zur DeploymentConfig, mit welcher man OpenShift sagt, wie eine Applikation deployt werden soll, definiert man mit dem ReplicationController, wie die Applikation während der Laufzeit aussehen soll (bspw. dass immer 3 Replicas laufen sollen).

**Tipp:** für jeden Resource Type gibt es auch eine Kurzform. So können Sie bspw. `oc get deploymentconfig` auch einfach als `oc get dc` schreiben.

---

## Zusatzaufgabe für Schnelle ;-)

Schauen Sie sich die erstellten Ressourcen mit `oc get [ResourceType] [Name] -o json` und `oc describe [ResourceType] [Name]` aus dem ersten Projekt `[USER]-example1` an.

---

**Ende Lab 4**

<p width="100px" align="right"><a href="05_create_route.md">Routen erstellen →</a></p>

[← zurück zur Übersicht](../README.md)
