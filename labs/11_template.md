# Lab 11: Application templates

In this lab we show how templates can describe entire infrastructures and can be instantiated with a command.

## Templates

As you've seen in the previous labs, you can easily create and deploy applications, databases, services, and their configuration by entering different commands.

This is error-prone and is not suitable for automating.

OpenShift offers the concept of templates in which you can describe a list of resources that can be parameterized. So you are almost a recipe for a whole infrastructure (for example, 3 application containers, a database with Persistent Storage)

**Note:** Clusteradmin can create global templates, which are available to all users.

View all existing templates

```bash
oc get template -n openshift
```

Using the Web Console, this can be done via "Add to Project". This functionality allows templates to be directly instantiated.

These templates can be stored in json format in the Git repository next to their source code, as well as via a URL called or even locally stored in the filesystem.

## Task: LAB11.1: Instance Template

The individual steps we have done manually in the previous labs can now be carried out using a template in a "slide".

```bash
oc new-project [USER]-template
```

Create template

```bash
$ oc create -f https://raw.githubusercontent.com/appuio/example-spring-boot-helloworld/master/example-spring-boot-template.json
[...]
```

instantiat template

```bash
$ oc new-app example-spring-boot

--> Deploying template example-spring-boot for "example-spring-boot"
     With parameters:
      APPLICATION_DOMAIN=
      MYSQL_DATABASE_NAME=appuio
      MYSQL_USER=appuio
      MYSQL_PASSWORD=appuio
      MYSQL_DATASOURCE=jdbc:mysql://mysql/appuio?autoReconnect=true
      MYSQL_DRIVER=com.mysql.jdbc.Driver
--> Creating resources ...
    imagestream "example-spring-boot" created
    deploymentconfig "example-spring-boot" created
    deploymentconfig "mysql" created
    route "example-spring-boot" created
    service "example-spring-boot" created
    service "mysql" created
--> Success
    Run 'oc status' to view your app.

```

With:

```bash
oc import-image example-spring-boot
```

the image will be imported and started.

With:

```bash
oc rollout latest mysql
```

the databasae will be deployed

**Hint:** You could also process templates directly by calling a template directly `$ oc new-app -f template.json -p Param = value`

To conclude this lab you can still see the template

```txt
https://github.com/appuio/example-spring-boot-helloworld/blob/master/example-spring-boot-template.json
```

**Note:** Existing resources can be exported as a template using the `oc export [ResourceType] --as-myapptemplate` Command.

For example:

```bash
oc export is,bc,dc,route,service --as-template=example-spring-boot -o json > example-spring-boot-template.json
```

It is important that the Imagestreams are defined at the top in the template file. Otherwise, the first build will not work.

---

**End Lab 11**

<p width="100px" align="right"><a href="12_template_creation.md">Create your own Templates →</a></p>

[← back to overview](../README.md)
