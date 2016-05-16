# Lab 1: Quicktour durch OpenShift V3

In diesem Lab werden die Grundkonzepte von OpenShift kurz aufgezeigt. Des Weiteren zeigen wir auf wie mach sich in de Web Console einlogged und stellen die einzelnen Bereiche kurz vor.

Die hier aufgeführten Begriffe und Resourcen sind ein Auszug aus der offiziellen OpenShift Dokumentation, weiterführende Informationen zu OpenShift können 

> https://docs.openshift.com/enterprise/3.1/architecture/index.html 

entnommen werden. 

## Grundkonzepte

OpenShift V3 basiert auf modernen Open Source Konzepten Docker und Kubernetes und bietet damit eine Plattform mit der Software in Containern gebuildet, deployed und betrieben werden kann. OpenShift V3 kann nebst Platform as a Service (PaaS) auch als Container Runtime bezeichnet werden.

### Docker

[Docker](https://www.docker.com/) ist die offene Plattform für Entwickler und Sysadmins und ihre Applikationen. Wählen Sie das für Ihre Technologie passende Basis-Docker-Image aus, OpenShift baut für Sie nach jedem Build automatisch einen aktualisierten Docker-Container und deployt ihn auf Wunsch auch gleich.

### Kubernetes 

Container orchestrieren und managen mit [Kubernetes](http://kubernetes.io/) von Google. Sie definieren wie viele Instanzen Ihrer Applikation parallel laufen sollen, Kubernetes kümmert sich um die Skalierung, das Loadbalancing und die Stabilität.

## Übersicht

![Overview](../images/ose3-overview.png)

### Container und Docker Images

Die Basis Elemente von OpenShift Applikationen sind Docker Container. Mit Docker Container können Prozesse auf einem Linuxsystem so isoliert werden, dass sie nur mit den definierten Resourcen interagieren können. So können viele unterschiedliche Container auf dem gleichen System laufen ohne, dass sie einander "sehen" (Files, Prozesse, Netzwerk). Typischerweise beinhaltet ein Container einen einzelnen Service (Webserver, Datenbank, Mailservice, Cache). Innerhalb von Docker Container können beliebige Prozesse ausgeführt werden.

Docker Container basieren auf Docker Images. Ein Docker Image ist eine binary Datei, die alle nötigen Komponenten beinhaltet, damit ein einzelner Container ausgeführt werden kann.

Docker Images werden anhand von DockerFiles(textueller Beschrieb wie das Docker Image Schritt für Schritt aufgebaut ist) gebuildet. Grundsätzlich sind Docker Images hierarchisch angewendete Filesystem Snapshots.

**Beispiel Tomcat**
- Basis Image (CentOs 7)
- + Install Java 
- + Install Tomcat
- + Install App

Die gebuildeten Docker Images werden in der OpenShift internen Docker Registry versioniert abgelegt und stehen der Plattform nach dem build dann zum Deployment zur Verfügung.

### Projekte

In OpenShift V3 werden Resourcen (Container und Docker Images, Pods, Services, Routen, Konfiguration, Quotas und Limiten ...) in Projekten strukturiert. Aus technischer Sicht entspricht ein Projekt einem Kubernetes namesapce und erweitert diesen um gewisse Konzepte. 

Innerhalb eines Projekts können berechtigte User Ihre Resourcen zu verwalten und organisieren. 

Die Resourcen innerhalb eines Projektes sind über ein transparentes [SDN](https://de.wikipedia.org/wiki/Software-defined_networking) verbunden. So können die einzelnen Komponeten eines Projektes in einem Multi-Node Setup auf verschiedene Nodes deployed werden.

### Pods

OpenShift übernimmt das Konzept der Pods von Kubernetes.

Ein Pod ist ein oder mehrere Container die zusammen auf dem gleichen Host deployed werden. Ein Pod ist die kleinste zu deployende Einheit auf OpenShift.

Ein Pod ist innerhalb einer OpenShift Projektes über den entsprechende Service verfügbar.

### Services

Ein Service repräsentiert einen internen Loadbalancer auf die dahinterliegenden Pods (Replicas vom gleichen Typ). Der Service dient als Proxy zu den Pods und leitet entsprechende Anfragen an die entsprechenden Pods weiter. So können entsprechend Pods willkürlich einem Service hinzugefügt und entfernt werden, während der Service verfügbar bleibt.

Einem Service ist innerhlab eines Projektes eine IP und einen Port zugewiesen und verteilt Requests entsprechend auf die Pod Replicas.

### Routen

Mit einer Route definiert man in OpenShift, wie ein Service von ausserhalb von OpenShift für externe Clients erreicht werden kann. 

Diese Routen werden so im integrierten Routing Layer eingetragen und erlauben dann der Plattform über ein Hostname Mapping die Requests an den entsprechenden Service weiterzuleiten.

Sind mehr als ein Pod für einen Service deployed verteilt der Routing Layer die Requests auf die deployeten Pods

Aktuell werden folgende Protokolle unterstützt:

- HTTP
- HTTPS ([SNI](https://en.wikipedia.org/wiki/Server_Name_Indication))
- WebSockets
- TLS mit [SNI](https://en.wikipedia.org/wiki/Server_Name_Indication)

### Templates

Ein Template beschreibt textuell eine Liste von Objekten, das auf OpenShift ausgeführt und die Objekte entsprechend in OpenShift erstellt werden können.

So hat man die Möglichkeit ganze Infrastrukturen zu beschreiben:

- Java Applikation Service (3 Replicas, rolling Upgrade)
- Datenbank Service
- über Route https://java.app.appuio-beta.ch im Internet verfügbar

---

**Ende Lab 1**

[<< zurück zur Übersicht] (../README.md)