# Tekton Pipelines

We will deploy an example application to test OpenShift Pipelines. This application let’s you vote what pet you like more: Cats or Dogs? It contais of a backend and a frontend part, which both will be deployed in a namespace.

## Basic Concepts

Tekton makes use of several custom resources (CRD). 

These CRDs are:

* *Task*: each step in a pipeline is a task, while a task can contain several steps itself, which are required to perform a specific task. For each Task a pod will be allocated and for each step inside this Task a container will be used. This helps in better scalability and better performance throughout the pipeline process.
* *Pipeline*: is a series of tasks, combined to work together in a defined (structured) way
* *TaskRun*: is the result of a Task, all combined TaskRuns are used in the PipelineRun 
* *PipelineRun*: is the actual execution of a whole Pipeline, containing the results of the pipeline (success, failed...)

Pipelines and Tasks should be generic and never define possible variables, like input git repository, directly in their definition. For this, the concept of PipelineResources has been created, which defines these parameters and which are used during a PipelineRun.

We start by creating a new project and a folder in which we will store our resource definitions:

```bash
$ oc new-project pipelines-userXY
$ mkdir tekton-pipelines
$ cd tekton-pipelines
```

The OpenShift Pipeline operator will automatically create a pipeline serviceaccount with all required permissions to build and push an image and which is used by PipelineRuns:

```bash
$ oc get sa
NAME       SECRETS   AGE
builder    2         11s
default    2         11s
deployer   2         11s
pipeline   2         11s
```

## Install tkn cli

For additional features, we are going to add another CLI that eases access to the Tekton resources and gives you a more direct access to the OpenShift Pipeline semantics:

```bash
curl -L https://github.com/tektoncd/cli/releases/download/v0.8.0/tkn_0.8.0_Linux_x86_64.tar.gz | tar xzvf - -C ~/bin tkn
```

Verify it by running:

```bash
$ tkn version
Client version: 0.8.0
Pipeline version: unknown
```


## Create a task

A Task is the smallest block of a Pipeline which by itself can contain one or more steps which are executed in order to process a specific element. For each Task a pod is allocated and each step is running in a container inside this pod. Tasks are reusable by other Pipelines. _Input_ and _Output_ specifications can be used to interact with other Tasks.

Let's create two tasks [Source: Pipeline-Tutorial](https://github.com/openshift/pipelines-tutorial/blob/master/01_pipeline)

```yaml
cat <<'EOF' > deploy-Example-Tasks.yaml
apiVersion: tekton.dev/v1alpha1
kind: Task
metadata:
  name: apply-manifests
spec:
  inputs:
    resources:
      - {type: git, name: source}
    params:
      - name: manifest_dir
        description: The directory in source that contains yaml manifests
        type: string
        default: "k8s"
  steps:
    - name: apply
      image: quay.io/openshift/origin-cli:latest
      workingDir: /workspace/source
      command: ["/bin/bash", "-c"]
      args:
        - |-
          echo Applying manifests in $(inputs.params.manifest_dir) directory
          oc apply -f $(inputs.params.manifest_dir)
          echo -----------------------------------
---
apiVersion: tekton.dev/v1alpha1
kind: Task
metadata:
  name: update-deployment
spec:
  inputs:
    resources:
      - {type: image, name: image}
    params:
      - name: deployment
        description: The name of the deployment patch the image
        type: string
  steps:
    - name: patch
      image: quay.io/openshift/origin-cli:latest
      command: ["/bin/bash", "-c"]
      args:
        - |-
          oc patch deployment $(inputs.params.deployment) --patch='{"spec":{"template":{"spec":{
            "containers":[{
              "name": "$(inputs.params.deployment)",
              "image":"$(inputs.resources.image.url)"
            }]
          }}}}'
EOF
```

Let's create the tasks:

```bash
oc create -f deploy-Example-Tasks.yaml
```

Verify that the two tasks have been created using the Tekton CLI:

```bash
$ tkn task ls
NAME                AGE
apply-manifests     7 minutes ago
update-deployment   7 minutes ago
```

## Create a Pipeline

A pipeline is a set of Tasks, which should be executed in a defined way to achieve a specific goal.

The example Pipeline below uses two resources:

* git-repo: defines the Git-Source
* image: Defines the target at a repository

It first uses the Task *buildah*, which is a standard Task the OpenShift operator created automatically. This task will build the image. The resulted image is pushed to an image registry, defined in the *output* parameter. After that our created tasks *apply-manifest* and *update-deployment* are executed. The execution order of these tasks is defined with the *runAfter* Parameter in the yaml definition.

NOTE: The Pipeline should be re-usable accross multiple projects or environments, thats why the resources (git-repo and image) are not defined here. When a Pipeline is executed, these resources will get defined.

```yaml
cat <<'EOF' > deploy-Example-Pipeline.yaml
apiVersion: tekton.dev/v1alpha1
kind: Pipeline
metadata:
  name: build-and-deploy
spec:
  resources:
  - name: git-repo
    type: git
  - name: image
    type: image
  params:
  - name: deployment-name
    type: string
    description: name of the deployment to be patched
  tasks:
  - name: build-image
    taskRef:
      name: buildah
      kind: ClusterTask
    resources:
      inputs:
      - name: source
        resource: git-repo
      outputs:
      - name: image
        resource: image
    params:
    - name: TLSVERIFY
      value: "false"
  - name: apply-manifests
    taskRef:
      name: apply-manifests
    resources:
      inputs:
      - name: source
        resource: git-repo
    runAfter:
    - build-image
  - name: update-deployment
    taskRef:
      name: update-deployment
    resources:
      inputs:
      - name: image
        resource: image
    params:
    - name: deployment
      value: $(params.deployment-name)
    runAfter:
    - apply-manifests
EOF
```

and create it:

```bash
oc create -f deploy-Example-Pipeline.yaml
```

Verify that the Pipeline has been created using the Tekton CLI:

```bash
$ tkn pipeline ls
NAME               AGE              LAST RUN   STARTED   DURATION   STATUS
build-and-deploy   34 seconds ago   ---        ---       ---        ---
```

## Trigger Pipeline

After the Pipeline has been created, it can be triggered to execute the Tasks.

###  Create PipelineResources

Since the Pipeline is generic, we need to define 2 *PipelineResources* first, to execute a Pipepline.
Our example application contains a frontend (vote-ui) AND a backend (vote-api), therefore 4 PipelineResources will be created. (2 times git repository to clone the source and 2 time output image)

Quick overview:

* ui-repo: will be used as _git_repo_ in the Pipepline for the Frontend
* ui-image: will be used as _image_ in the Pipeline for the Frontend
* api-repo: will be used as _git_repo_ in the Pipepline for the Backend
* api-image: will be used as _image_ in the Pipeline for the Backend

**Note:** Make sure you adapt the image registry with your project name!

```yaml
cat <<'EOF' > deploy-Example-PipelineResources.yaml
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: ui-repo
spec:
  type: git
  params:
  - name: url
    value: http://github.com/openshift-pipelines/vote-ui.git
---
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: ui-image
spec:
  type: image
  params:
  - name: url
    value: image-registry.openshift-image-registry.svc:5000/pipelines-userXY/vote-ui:latest
---
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: api-repo
spec:
  type: git
  params:
  - name: url
    value: http://github.com/openshift-pipelines/vote-api.git
---
apiVersion: tekton.dev/v1alpha1
kind: PipelineResource
metadata:
  name: api-image
spec:
  type: image
  params:
  - name: url
    value: image-registry.openshift-image-registry.svc:5000/pipelines-userXY/vote-api:latest
EOF
```

And create them:

```bash
oc create -f deploy-Example-PipelineResources.yaml
```

The resources can be listed with:

```bash
$ tkn resource ls
NAME        TYPE    DETAILS
api-repo    git     url: http://github.com/openshift-pipelines/vote-api.git
ui-repo     git     url: http://github.com/openshift-pipelines/vote-ui.git
api-image   image   url: image-registry.openshift-image-registry.svc:5000/pipelines-userXY/vote-api:latest
ui-image    image   url: image-registry.openshift-image-registry.svc:5000/pipelines-userXY/vote-ui:latest
```

### Execute Pipelines

We start a PipelineRune for the backend and frontend of our application.

```yaml
cat <<'EOF' > deploy-Example-PipelineRun.yaml
apiVersion: tekton.dev/v1alpha1
kind: PipelineRun
metadata:
  name: build-deploy-api-pipelinerun
spec:
  pipelineRef:
    name: build-and-deploy
  resources:
  - name: git-repo
    resourceRef:
      name: api-repo
  - name: image
    resourceRef:
      name: api-image
  params:
  - name: deployment-name
    value: vote-api
---
apiVersion: tekton.dev/v1alpha1
kind: PipelineRun
metadata:
  name: build-deploy-ui-pipelinerun
spec:
  pipelineRef:
    name: build-and-deploy
  resources:
  - name: git-repo
    resourceRef:
      name: ui-repo
  - name: image
    resourceRef:
      name: ui-image
  params:
  - name: deployment-name
    value: vote-ui
EOF
```

And start it's execution:

```bash
$ oc create -f deploy-Example-PipelineRun.yaml
```

The PipelineRuns can be listed with

```bash
$ tkn pipelinerun ls

NAME                           STARTED         DURATION   STATUS
build-deploy-api-pipelinerun   3 minutes ago   ---        Running
build-deploy-ui-pipelinerun    3 minutes ago   ---        Running
```

Moreover, the logs can be viewed with the following command and select the appropriate PipelineRun:

```bash
tkn pipeline logs -f
```

And select one of the runs to follow it logs.

## OpenShift WebUI

With the OpenShift Pipeline operator a new menu item is introduced on the WebUI of OpenShift. All Tekton CLI command which are used above, can actually be replaced with the web interface, in case you prefere this. The big advantage is th graphical presentation of Pipelines and their lifetime.


### Checking your application

Now our Pipeline built and deployed the voting application, where you can vote if you prefere cats or dogs (Cats or course :) )

Get the route of your project and open the URL in the browser.
