# OpenShift Developer Techlab

## Agenda

### 1. Tag

* [Mit der Umgebung vertraut machen](01_using_oc_cli.md)
* [Builds](02_builds.md)
* [Applikationen entwickeln](03_develop.md)

### 2. Tag

* [Debugging / Logging / Metrics](04_debugging_logs_metrics.md)

### Anforderungen an die Dev-Labs

#### Lab 01

* techlab Benutzergruppe
* openshift-web-console Projekt: view-Rechte für die techlab-Benutzergruppe

#### Lab 02

* Repo: dieses techlab Repo
* Repo: <https://github.com/appuio/example-php-sti-helloworld>
* War-File: <https://github.com/appuio/hello-world-war/blob/master/repo/ch/appuio/hello-world-war/1.0.0/hello-world-war-1.0.0 .war? raw = true>
* OpenShift ImageStream: openshift/php:7.1
* Docker Hub Image: "openshift/wildfly-160-centos7"
* Docker Hub Image: "centos/httpd-24-centos7"

#### Lab 03

* Repo: dieses techlab Repo
* Docker Hub Image: "appuio/example-spring-boot"
* OpenShift Template: openshift/mysql-persistent

#### Lab 04

* OpenShift Projekt aus Lab 03: [USER]-dockerimage
* Repo: https://github.com/chrira/ruby-ex.git#load
* OpenShift ImageStream: : "openshift/ruby:2.5"
* OpenShift metrics server: <https://docs.openshift.com/container-platform/3.11/dev_guide/pod_autoscaling.html>
  * Test: `oc get project | grep openshift-metrics-server`
