# Lab 9: Integrating Code Changes Via Webhook

In this lab we'll show you the Docker build workflow and how to push a build and deploy the application to OpenShift with a push into a Git repository.

## Task: LAB9.1: Preparation of Github Account and Fork

### Github Account

In order to make changes to the source code of our example application, you need a separate GitHub account. If you do not already have one, set up an account at https://github.com/.

### Fork Example-Project

**Example-Project:** https://github.com/appuio/example-php-docker-helloworld

Go to [GitHub Projekt-Seite](https://github.com/appuio/example-php-docker-helloworld) and [fork](https://help.github.com/articles/fork-a-repo/) the project.

![Fork](../images/lab_9_fork_example.png)

You now have

```txt
https://github.com/[YourGitHubUser]/example-php-docker-helloworld
```

a fork of the Example project that you can expand as you want.

## Deployen your own fork

Create a new project:

```bash
oc new-project [USER]-example4
```

Create a new app for your fork.  **Note:** Replace `[YourGithubUser]` with the name of your GitHub account:

```bash
oc new-app https://github.com/[YourGithubUser]/example-php-docker-helloworld.git --strategy=docker --name=appuio-php-docker-ex
```

By means of the parameter  `--strategy=docker` we explicitly tell the `oc new-app` command to look for a Dockerfile in the specified Git repository and use it for the build.

Now expose the service with:

```bash
oc expose service appuio-php-docker-ex
```

## Task: LAB9.2: Set up web hook on GitHub

When creating the app, BuildConfig (bc) directly defined webhooks. You can do this by using the following command:

```bash
$ oc describe bc appuio-php-docker-ex

Name:		appuio-php-docker-ex
Created:	57 seconds ago
Labels:		app=appuio-php-docker-ex
Annotations:	openshift.io/generated-by=OpenShiftNewApp
Latest Version:	1

Strategy:		Docker
URL:			https://github.com/appuio/example-php-docker-helloworld.git
From Image:		ImageStreamTag php-56-centos7:latest
Output to:		ImageStreamTag appuio-php-docker-ex:latest
Triggered by:		Config, ImageChange
Webhook Generic:	https://master.appuio-beta.ch:443/oapi/v1/namespaces/techlab-example4/buildconfigs/appuio-php-docker-ex/webhooks/EqEq18JtxaY3vG2zvPSU/generic
Webhook GitHub:		https://master.appuio-beta.ch:443/oapi/v1/namespaces/techlab-example4/buildconfigs/appuio-php-docker-ex/webhooks/hqQ3h1CzUGIXvWqjiV-G/github

Build			Status		Duration		Creation Time
appuio-php-docker-ex-1 	running 	running for 56s 	2016-06-17 16:56:34 +0200 CEST


```

You can also copy the GitHub WebHook from the Web Console. To do this, go to the appropriate build using Builds → Builds and select the Configuration tab:

![Webhook](../images/lab_9_webhook_ose3.png)

Copy the GitHub [Webhook](https://developer.github.com/webhooks/) URL and paste it into GitHub.

In your project, click Settings:
![Github Webhook](../images/lab_09_webhook_github1.png)

Click Webhooks & services:
![Github Webhook](../images/lab_09_webhook_github2.png)

Add a WebHook:
![Github Webhook](../images/lab_09_webhook_github3.png)

Insert the appropriate GitHub WebHook URL from your OpenShift project and "disable" the SSL verification. On the Lab platform we have only self-signed certificates.
![Github Webhook](../images/lab_09_webhook_github4.png)

From now, all pushes on your GitHub repository triggers a build and then deploy the code changes directly to the OpenShift platform.

## Task: LAB9.3: Adjust the code


Now clone your git-repository and change into the code directory:

```bash
$ git clone https://github.com/[YourGithubUser]/example-php-docker-helloworld.git
[...]
$ cd example-php-docker-helloworld
```

Edit the following file, for example on line 56 ./app/index.php:

```bash
vim app/index.php
```

![Github Webhook](../images/lab_9_codechange1.png)

```html
    <div class="container">

      <div class="starter-template">
        <h1>Hallo <?php echo 'OpenShift Techlab'?></h1>
        <p class="lead">APPUiO Example Dockerfile PHP</p>
      </div>

    </div>
```

Now push your changes:

```bash
$ git add .
$ git commit -m "updated Hello"
$ git push
[...]
```

As an alternative you can edit the file directly on GitHub:
![Github Webhook](../images/lab_9_edit_on_github.png)

As soon as you pushed your changes, OpenShift will start a new build of the source code:

```bash
oc get builds
```

and deployes it afterwards.

## Task: LAB9.4: Rollback

With OpenShift, different software versions can be activated and deactivated by simply starting another version of the image.

The command `oc rollback` and `oc rollout` are used for this purpose.

To run a rollback, you need the name of the DeploymentConfig:

```bash
$ oc get dc

NAME                   REVISION   DESIRED   CURRENT   TRIGGERED BY
appuio-php-docker-ex   4          1         1         config,image(appuio-php-docker-ex:latest)

```

Use the following command to roll back to the previous version:

```bash
$ oc rollback appuio-php-docker-ex
#3 rolled back to appuio-php-docker-ex-1
Warning: the following images triggers were disabled: appuio-php-docker-ex:latest
  You can re-enable them with: oc set triggers dc/appuio-php-docker-ex --auto
```

As soon as the deployment of the old version is done, you can check in your Browser if the original Titel **Hello APPUiO** is back.

**Hint:** The automatic deployments of new versions are now switched off for this application to prevent unintentional changes after the rollback. To turn automatic deployment back on, run the following command:

```bash
oc set triggers dc/appuio-php-docker-ex --auto
```

---

**Ende Lab 9**

<p width="100px" align="right"><a href="10_persistent_storage.md">Persistent Storage and use for database →</a></p>

[← back to overview](../README.md)
