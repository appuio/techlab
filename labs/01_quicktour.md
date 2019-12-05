# Lab 1: Quicktour durch OpenShift

In diesem Lab werden die Grundkonzepte von OpenShift vorgestellt. Des Weiteren zeigen wir auf, wie man sich in der Web Console einloggt und stellen die einzelnen Bereiche kurz vor.

Die hier aufgeführten Begriffe und Ressourcen sind ein Auszug [dieses Red Hat Blogposts](https://developers.redhat.com/blog/2018/02/22/container-terminology-practical-introduction/), dem auch weiterführende Informationen zu Begriffen rund um Container entnommen werden können.


## Grundkonzepte

OpenShift basiert auf modernen Konzepten wie CRI-O oder Kubernetes und bietet damit eine Plattform, mit der Software in Containern gebaut, deployt und betrieben werden kann.


### Container Engine

[cri-o](https://cri-o.io/) ist eine leichtgewichtige Container Engine, welche Container Images in einen laufenden Prozess umwandelt, also in einen Container. Dies geschieht anhand der [Container Runtime Specification](https://github.com/opencontainers/runtime-spec) der [Open Container Initiative](https://www.opencontainers.org/), welche auch die [Image Specification](https://github.com/opencontainers/image-spec) festgelegt hat. Sämtliche OCI-konformen Images können so mit OCI-konformen Engines ausgeführt werden.


### Kubernetes

[Kubernetes](http://kubernetes.io/) ist ein Container Orchestration Tool, welches das Verwalten von Containern wesentlich vereinfacht. Der Orchestrator terminiert dynamisch den Container Workload innerhalb eines Clusters.


### Container und Container Images

Die Basiselemente von OpenShift Applikationen sind Container. Ein Container ist ein isolierter Prozess auf einem Linuxsystem mit eingeschränkten Ressourcen, der nur mit definierten Prozessen interagieren kann.

Container basieren auf Container Images. Ein Container wird gestartet, indem die Container Engine die Dateien und Metadaten des Container Images entpackt und dem Linux Kernel übergibt.

Container Images werden bspw. anhand von Dockerfiles (textueller Beschrieb, wie das Container Image Schritt für Schritt aufgebaut ist) gebaut. Grundsätzlich sind Container Images hierarchisch angewendete Filesystem Snapshots.

**Beispiel Tomcat**

- Base Image (z.B. [UBI](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image))
- + Java
- + Tomcat
- + App

Gebaute Container Images werden in einer Image Registry (analog einem Repository für bspw. RPM-Pakete) versioniert abgelegt und können von da bezogen werden, um sie auf einer Container Plattform zu deployen.
Container Images können auch auf OpenShift selbst gebaut werden, von wo aus sie in die OpenShift-interne Registry gepusht und für das Deployment wieder gepullt werden.


## OpenShift-Konzepte

### Projekte

In OpenShift werden Ressourcen (Container und Container Images, Pods, Services, Routen, Konfiguration, Quotas und Limiten etc.) in Projekten strukturiert. Aus technischer Sicht entspricht ein Projekt einem Kubernetes Namespace und erweitert diesen um gewisse Konzepte.

Innerhalb eines Projekts können berechtigte User ihre Ressourcen selber verwalten und organisieren.

Die Ressourcen innerhalb eines Projektes sind über ein transparentes [SDN](https://de.wikipedia.org/wiki/Software-defined_networking) bzw. Overlay-Netzwerk verbunden. So können die einzelnen Komponenten eines Projektes in einem Multi-Node Setup auf verschiedene Nodes deployed werden. Dabei sind sie über das SDN untereinander sicht- und zugreifbar.


### Pods

OpenShift übernimmt das Konzept der Pods von Kubernetes.

Ein Pod ist ein oder mehrere Container, die zusammen auf den gleichen Host deployed werden. Ein Pod ist die kleinste verwaltbare Einheit in OpenShift.

Ein Pod ist innerhalb eines OpenShift Projekts u.a. über den entsprechenden Service verfügbar.


### Services

Ein Service repräsentiert einen internen Loadbalancer auf die dahinterliegenden Pods (Replicas vom gleichen Typ). Der Service dient als Proxy zu den Pods und leitet Anfragen an diese weiter. So können Pods willkürlich einem Service hinzugefügt und entfernt werden, während der Service verfügbar bleibt.

Einem Service ist innerhalb eines Projektes eine IP und ein Port zugewiesen.


### Routes

Mit einer Route definiert man in OpenShift, wie ein Service von ausserhalb von OpenShift von externen Clients erreicht werden kann.

Diese Routes werden im integrierten Routing Layer eingetragen und erlauben dann der Plattform über ein Hostname-Mapping die Requests an den entsprechenden Service weiterzuleiten.

Sind mehr als ein Pod für einen Service deployt, verteilt der Routing Layer die Requests auf die deployten Pods.

Aktuell werden folgende Protokolle unterstützt:

- HTTP
- HTTPS ([SNI](https://en.wikipedia.org/wiki/Server_Name_Indication))
- WebSockets
- TLS-verschlüsselte Protokolle mit [SNI](https://en.wikipedia.org/wiki/Server_Name_Indication)


### Templates

Ein Template beschreibt textuell eine Liste von Ressourcen, die auf OpenShift ausgeführt und entsprechend in OpenShift erstellt werden können.

So hat man die Möglichkeit ganze Infrastrukturen zu beschreiben:

- Java Application Service (3 Replicas, Rolling Upgrade)
- Datenbank Service
- Im Internet über Route java.app.appuio-beta.ch erreichbar
- ...

---

**Ende Lab 1**

<p width="100px" align="right"><a href="02_cli.md">OpenShift CLI installieren →</a></p>

[← zurück zur Übersicht](../README.md)
