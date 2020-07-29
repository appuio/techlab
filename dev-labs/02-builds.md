# Builds

There are three different types of builds:

1. Source-To-Image (s2i)
2. Binary Builds
3. Container aka. Docker Builds

Let's have a look at the different kinds of builds

## Source-To-Image

Simplest way of getting started from a code base (e.g. Ruby, Python, PHP) to a running application bundled with all the dependencies.

It creates all the necessary Build Configs, deployment configs and even automatically creates the service.

Our example is based on a very simple Ruby application hosted on gitlab.

    oc new-project s2i-userXY
    oc new-app -h
    oc new-app ruby:2.5~https://git.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com/training/ruby-ex.git
    oc status


Explore the different resources created by the new-app command.

To access the built and deployed application we must expose it as a route. We can do that by issuing the following command:

    oc create route edge --insecure-policy=Allow --service=ruby-ex

By describing the route, we can get the URL that serves your built ruby application. Access it through your browser. You find the URL as well in the web console. Inspect your application there as well.

## Binary build

This example describes how to deploy a web archive (war) in Wildfly using the OpenShift client (oc) in binary mode.
The example is inspired by APPUiO blog: <http://docs.appuio.ch/en/latest/app/wildflybinarydeployment.html>

### Create a new project

```bash
oc new-project binary-build-userXY
```

### Create the deployment folder structure

Prepare a temporary folder and create the deployment folder structure inside.

One or more war can be placed in the deployments folder. In this example an existing war file is downloaded from a Git repository:

```bash
mkdir tmp-bin
cd tmp-bin
mkdir deployments
wget -O deployments/ROOT.war https://git.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com/training/techlab/raw/master/data/hello-world-war-1.0.0.war
```

### Create a new build using the Wildfly image

The flag *binary=true* indicates that this build will use the binary content instead of the url to the source code.

Command:

```bash
oc new-build --docker-image=openshift/wildfly-160-centos7 --binary=true --name=hello-world -l app=hello-world
```

Command with output:

```bash
$ oc new-build --docker-image=openshift/wildfly-160-centos7 --binary=true --name=hello-world -l app=hello-world
--> Found Docker image 5b42148 (6 weeks old) from Docker Hub for "openshift/wildfly-160-centos7"

    WildFly 16.0.0.Final 
    -------------------- 
    Platform for building and running JEE applications on WildFly 16.0.0.Final

    Tags: builder, wildfly, wildfly16

    * An image stream will be created as "wildfly-160-centos7:latest" that will track the source image
    * A source build using binary input will be created
      * The resulting image will be pushed to image stream "hello-world:latest"
      * A binary build was created, use 'start-build --from-dir' to trigger a new build

--> Creating resources with label app=hello-world ...
    imagestream "wildfly-160-centos7" created
    imagestream "hello-world" created
    buildconfig "hello-world" created
--> Success
```

See the command output for the created resources.

Check the created resources with the oc tool and inside the web console.

## Start the build

To trigger a build issue the command below. In a continuous deployment process this command can be repeated
whenever there is a new binary or a new configuration available.

The core feature of the binary build is to provide the files for the build from the local directory.
Those files will be loaded into the build container that runs inside OpenShift.

```bash
oc start-build hello-world --from-dir=. --follow
```

The parameter _--from-dir=._ tells the oc tool which directory to upload.

The _--follow_ flag will show the build log on the console and wait until the build is finished.

### Create a new app

```bash
oc new-app hello-world -l app=hello-world
```

See the command output for the created resources.

Check the created resources with the oc tool and inside the web console.
Try to find out, if the wildfly has started.

### Expose the service as route

```bash
oc create route edge --insecure-policy=Allow --service=hello-world
```

Inside the web console click onto the route to see the output of the hello-world application.

## Container Build

We can also create arbitrary containers based on Dockerfiles.

Command:

```bash
oc new-project docker-build-userXY
oc new-build --strategy=docker https://git.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com/training/httpd.git
```

Follow how the build goes and if the image will be present in your registry.

Create an app with that image and expose it:

```bash
oc new-app httpd -l app=httpd
oc create route edge --insecure-policy=Allow --service=httpd
```

Now let's try to add an easter egg in /egg.txt with a new build. How would you do this and where should it be done?
