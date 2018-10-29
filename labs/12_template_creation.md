# Lab 12: Create your own Templates

In contrast to [Lab 11](11_template.md) we write / define our own templates before we create applications.

## Helpful oc client commands
List all commands:

```bash
oc help
```

Concepts and types:

```bash
oc types
```

Overview of all resources:

```bash
oc get all
```

Information about a resource:

```bash
oc get <RESOURCE_TYPE> <RESOURCE_NAME>
oc describe <RESOURCE_TYPE> <RESOURCE_NAME>
```

## Generation

The resources are created automatically via "oc new-app" or "Add to project" in the web console. In the web console, the creation can be easily configured.

This is usually not enough for productive use. Because it takes more control over the configuration. Own templates are the solution for this. However, they must not be written by hand but can be generated as a template.

### Generation before creation

With `oc new-app` OpenShift parses the given images, templates, source code repositories, etc., and creates the definition of the various resources. The option `-o` provides the definition without the resources being created.

This is the definition of the hello-world image.

```bash
oc new-app hello-world -o json
```

Exciting is also to observe what OpenShift is doing for your own project. A Git repository or a local path of the computer can be specified for this purpose.

Sample command when you are in the root directory of the project:

```bash
oc new-app . -o json
```

If different ImageStreams are in question or none has been found, it must be specified:

```bash
oc new-app . --image-stream=wildfly:latest -o json
```

`oc new-app` always creates a list of resources. If necessary, this can be converted to a template using [jq](https://stedolan.github.io/jq/):

```bash
$ oc new-app . --image-stream=wildfly:latest -o json | \
  jq '{ kind: "Template", apiVersion: .apiVersion, metadata: {name: "mytemplate" }, objects: .items }'
```

### Generation after creation

Existing resources are exported with  `oc export`.

```bash
oc export route my-route
```

What resources does it need?

The following resources are required for a complete template:
* Image Streams
* Build Configurations
* Deployment Configurations
* Persistent Volume Claims
* Routes
* Services

Example command to generate an export of the most important resources as a template:

```bash
oc export is,bc,pvc,dc,route,service --as-template=my-template -o json > my-template.json
```

Without the `--as-template` option, a list of items would be exported instead of a template containing Objects.

Currently, there is an open [Issue](https://github.com/openshift/origin/issues/8327) which causes ImageStreams to stop working properly after re-importing. As a workaround, the attribute `.spec.dockerImageRepository`, f if present, can be replaced with the value of the attribute `.tags[0].annotations["openshift.io/imported-from"]`. With [jq](https://stedolan.github.io/jq/) this can be done automatically:

```bash
$ oc export is,bc,pvc,dc,route,service --as-template=my-template -o json |
  jq '(.objects[] | select(.kind == "ImageStream") | .spec) |= \
    (.dockerImageRepository = .tags[0].annotations["openshift.io/imported-from"])' > my-template.json
```

Attributes with value `null` sand the annotation `openshift.io/generated-by` may be removed from the template.

### Export existing templates

You can also retrieve existing templates from the platform to create your own templates.

Available templates are stored in the OpenShift Namespace. This is how all templates are listed:

```bash
oc get templates -n openshift
```

So we get a copy of the eap70-mysql-persistent-s2i template:

```bash
oc export template eap70-mysql-persistent-s2i -o json -n openshift > eap70-mysql-persistent-s2i.json
```

## Parameters
In order for the applications to be adapted for their own needs, there are parameters. Generated or exported templates should replace fixed values, such as host names or passwords, with parameters.

### Display the parameters of templates
The parameters of a template are displayed with `oc process --parameters`. Here we will see which parameters are defined in the CakePHP MySQL Template:

```bash
$ oc process --parameters cakephp-mysql-example -n openshift
NAME                           DESCRIPTION                                                                GENERATOR VALUE
NAME                           The name assigned to all of the frontend objects defined in this template.           cakephp-mysql-example
NAMESPACE                      The OpenShift Namespace where the ImageStream resides.                               openshift
MEMORY_LIMIT                   Maximum amount of memory the CakePHP container can use.                              512Mi
MEMORY_MYSQL_LIMIT             Maximum amount of memory the MySQL container can use.                                512Mi
...
```

### Replace the parameters of templates with values

For the creation of the applications, desired parameters can be replaced with values. To do this `oc process`:

```bash
oc process -f eap70-mysql-persistent-s2i.json \
  -v PARAM1=value1,PARAM2=value2 > processed-template.json
```

This will replace the template with the given values ​​and write it to a new file. This file will be a list of Resources / Items that can be created with  `oc create`:

```bash
oc create -f processed-template.json
```

This can also be done in one step:

```bash
oc process -f eap70-mysql-persistent-s2i.json \
  -v PARAM1=value1,PARAM2=value2 \
  | oc create -f -
```

## Write templates
OpenShift Documentation:
* [Template Konzept](https://docs.openshift.com/container-platform/3.5/architecture/core_concepts/templates.html)
* [Templates schreiben](https://docs.openshift.com/container-platform/3.5/dev_guide/templates.html)

Applications should be designed so that only a few configurations differ per environment. These values ​​are defined as parameters in the template. Thus, the first step after generating a template definition is to define parameters. The template is expanded with variables, which are then replaced with the parameter values. Thus, the variable `${DB_PASSWORD}` is replaced by the parameter with the name `DB_PASSWORD`.

### Generated parameters

Passwords are often generated automatically because the value is only used in the OpenShift project. This can be achieved with a generate definition.

```json
parameters:
  - name: DB_PASSWORD
    description: "DB connection password"
    generate: expression
    from: "[a-zA-Z0-9]{13}"
```

This definition would generate a random, 13-character password with small and uppercase letters as well as numbers.

Even if a parameter is configured with Generate Definition, it can be overwritten during generation.

### Template Merge
For example, if an app is used together with a database, the two templates can be merged. It is important to consolidate the template parameters. These are usually values for the connection of the database. Simply use the same variable from the common parameter in both templates.

## Apply From templates

Templates can be instantiated using `oc new-app -f <FILE>|<URL> -p <PARAM1>=<VALUE1>,<PARAM2>=<VALUE2>...`.
If the parameters of the template have already been set with `oc process`, it is no longer necessary to specify the parameters.

### Metadata / Labels
`oc new-app` inserts the label `app=<TEMPLATE NAME>` into all instanced resources by default. For some versions of OpenShift, this can lead to [invalid](https://github.com/openshift/origin/issues/10782) Rresource definitions. As a workaround, an alternative label can be configured with `oc new-app -l <LABEL NAME>=<LABEL VALUE> ...`.

## Create resources from docker-compose.yml

Since version 3.3, the OpenShift Container Platform offers the possibility to create resources from the Docker Compose configuration file `docker-compose.yml`. This functionality is still classified as experimental. Example:

```bash
git clone -b techlab https://github.com/appuio/weblate-docker.git
oc import docker-compose -f docker-compose.yml -o json
```

The possibility to import a file directly via URL is provided but not yet implemented. By omitting the -o json option, the resources are created directly instead of outputting. Currently, services for existing docker images are created only if an explicit port configuration is present in `docker-compose.yml`. These can be created in the meantime using `oc new-app`:

```bash
oc new-app --name=database postgres:9.4 -o json|jq '.items[] | select(.kind == "Service")' | oc create -f -
oc new-app --name=cache memcached:1.4 -o json|jq '.items[] | select(.kind == "Service")'|oc create -f -
```

---

**End Lab 12**

[← back to overview](../README.md)
