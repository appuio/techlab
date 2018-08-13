# Lab 1: Quicktour through OpenShift V3

In this lab the basic concepts of OpenShift are presented. We will also show you how to log in to the web console and briefly present the individual areas.

The terms and resources listed here are an excerpt from the official OpenShift documentation, further information about OpenShift can be found here:

> https://docs.openshift.com/container-platform/3.5/architecture/index.html

## Basic concepts

OpenShift V3 is based on modern Open Source concepts such as Docker and Kubernetes, providing a platform that can be used to build, deploy, and operate software in containers. OpenShift V3 can be called Container Platform or Platform as a Service (PaaS).

### Docker

[Docker](https://www.docker.com/) is the open platform for developers and sysadmins and their applications. Choose the base docker images that match your technology, and OpenShift automatically builds an updated Docker container after you build it, and deploy it as you want.

### Kubernetes

Orchestrate and manage containers with[Kubernetes](http://kubernetes.io/) by Google. You define how many instances of your application should run in parallel, and Kubernetes takes care of the scaling, load balancing and stability.

## Overview

![Overview](../images/ose3-overview.png)

### Container und Docker Images

The basic elements of OpenShift applications are docker containers. With docker containers, processes on a Linux system can be isolated so that they can only interact with the defined resources. This allows many different containers to run on the same system without seeing each other (files, processes, network). Typically, a container contains a single service (web server, database, mail service, cache). Within a Docker container, any process can be executed.

Docker containers are based on docker images. A docker image is a binary file that contains all the necessary components to run a single container.

Docker images are created by dockerfiles (textual description of how the docker image is built step by step). Basically, docker images are hierarchically applied file system snapshots.

**Tomcat Example**
- Basis Image (CentOs 7)
- + Install Java
- + Install Tomcat
- + Install App

The docker images are stored in version control in the OpenShift internal Docker Registry and are available to the platform for deployment after the build.

### Projects

In OpenShift V3, resources (containers and docker images, pods, services, routes, configuration, quotas and limits etc.) are structured in projects. From a technical point of view, a project corresponds to a Kubernetes namespace and extends these concepts with certain concepts.

Within a project, authorized users can manage and organize their own resources.

Die Ressourcen innerhalb eines Projektes sind über ein transparentes [SDN](https://de.wikipedia.org/wiki/Software-defined_networking) verbunden. So können die einzelnen Komponenten eines Projektes in einem Multi-Node Setup auf verschiedene Nodes deployed werden. Dabei sind sie über das SDN untereinander sicht- und zugreifbar.

### Pods

OpenShift übernimmt das Konzept der Pods von Kubernetes.

Ein Pod ist ein oder mehrere Container, die zusammen auf den gleichen Host deployed werden. Ein Pod ist die kleinste zu deployende Einheit auf OpenShift.

Ein Pod ist innerhalb eines OpenShift Projektes über den entsprechenden Service verfügbar.

### Services

Ein Service repräsentiert einen internen Loadbalancer auf die dahinterliegenden Pods (Replicas vom gleichen Typ). Der Service dient als Proxy zu den Pods und leitet Anfragen an diese weiter. So können Pods willkürlich einem Service hinzugefügt und entfernt werden, während der Service verfügbar bleibt.

Einem Service ist innerhalb eines Projektes eine IP und ein Port zugewiesen und verteilt Requests entsprechend auf die Pod Replicas.

### Routen

Mit einer Route definiert man in OpenShift, wie ein Service von ausserhalb von OpenShift von externen Clients erreicht werden kann.

Diese Routen werden im integrierten Routing Layer eingetragen und erlauben dann der Plattform über ein Hostname-Mapping die Requests an den entsprechenden Service weiterzuleiten.

Sind mehr als ein Pod für einen Service deployt, verteilt der Routing Layer die Requests auf die deployten Pods

Aktuell werden folgende Protokolle unterstützt:

- HTTP
- HTTPS ([SNI](https://en.wikipedia.org/wiki/Server_Name_Indication))
- WebSockets
- TLS mit [SNI](https://en.wikipedia.org/wiki/Server_Name_Indication)

### Templates

Ein Template beschreibt textuell eine Liste von Ressourcen, die auf OpenShift ausgeführt und entsprechend in OpenShift erstellt werden können.

So hat man die Möglichkeit ganze Infrastrukturen zu beschreiben:

- Java Applikation Service (3 Replicas, rolling Upgrade)
- Datenbank Service
- über Route https://java.app.appuio-beta.ch im Internet verfügbar

---

**Ende Lab 1**

<p width="100px" align="right"><a href="02_cli.md">install OpenShift CLI →</a></p>

[← back to overview](../README.md)
