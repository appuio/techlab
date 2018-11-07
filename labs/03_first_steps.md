# Lab 3: First Steps

In this lab, we will be interacting with the Lab platform for the first time, via the oc client as well as the web console

## Login

**Note:** Make sure you have successfully completed [Lab 2](02_cli.md).

Please use the information provided by the instructor for the login on the web interface as well as with oc.

## Create a project

A project in OpenShift is the top level concept to organize your applications, deployments, builds, containers, etc. See [Lab1](01_quicktour.md).


## Task: LAB3.1
Create a new project on the lab plattform.

**Note**: For your project name, use your github name or your last name, for example:`[USER]-example1`

> How can I create a new project?

**Hint**:  the oc tool has a built-in help function:
```
$ oc help
```

## Web Console

The OpenShift V3 Web Console allows users to perform certain tasks directly via a browser.

## Task: LAB3.2

1. Log on to the Lab platform using the Web Console.

  **Note:** The **URL**, ser name and password for your account will be provided to you by the Instructor.

2. Now go to the overview of your newly created project. Currently the project is still empty.

3. Add your first application to your project using *Add to Project*. As an example project we use an APPUiO Example.

  3.1. To start choose the base Image **php 5.6**
![php5.6](../images/lab_3_php5.6.png)

  3.2. Give your example a recognisable name and the following URL as Repo URL
  ```
  https://github.com/appuio/example-php-sti-helloworld.git
  ```
![php5.6](../images/lab_3_example1.png)

4. The application has been created. The link **Go to overview** gives you an overview.

5. The build of your application is started. Follow the build and look at the sample app after deployment.

![php5.6](../images/lab_3_example1-deployed.png)

You have now deployed your first application using the so-called **[Source to Image](https://docs.openshift.com/container-platform/3.5/architecture/core_concepts/builds_and_image_streams.html#source-build)** build on OpenShift deployed.

**Hint:** Use the following command to switch to another project:
```
$ oc project [projectname]
```

**Hint:** The following commands can be used to create the above example from the command line:
```
$ oc new-app https://github.com/appuio/example-php-sti-helloworld.git --name=appuio-php-sti-example
$ oc expose svc appuio-php-sti-example
```

**Hint:** a whole app can be deleted with the following command:

```
$ oc delete all -l app=appname
```

For example:

```
$ oc delete all -l app=appuio-php-sti-example
```

---

## Solution: LAB3.1

```
$ oc new-project [USER]-example1
```
---

**End of lab 3**

<p width="100px" align="right"><a href="04_deploy_dockerimage.md">Deploying a Docker Image→</a></p>

[← back to overview](../README.md)
