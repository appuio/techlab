# Pipelines and Jenkins on OpenShift

OpenShift comes with a Jenkins image that is opinionated and pre-configured to allow jobs to be scheduled on the Kubernetes cluster. Moreover, the following features all together create a very good user experience when using Jenkins together with OpenShift:

- Jenkins is configured for OAuth2 based Authentication and Authorisation towards Openshift
- Jenkins can schedule slave pods with different build tools on demand
- Builds with *Pipeline* strategy are executed by Jenkins without any interaction on Jenkins, one console to rule them all
- Objects such as ConfigMaps and Secrets from OpenShift are synced/copied into Jenkins

## CI/CD Principles in a nutshell

When dealing with containers in a CI/CD settings the following principles are very important:

- Container images should be built once and only once. If you have to build different images per stage, something went wrong :(
- For configuring stage dependant things such as database credentials & coordinates, MQ related settings and general application configuration, use environment values, configuration files that are populated via ConfigMaps and/or Secrets.
- Container images should be tagged so that matching software/code is visible
- Changes from one stage to the next, should be applied via automation and without any manual intervention. Changes should be reproducible and traceable.

## Pipelines

One of the primary build strategies that come with the OpenShift Container Platform is called the **Pipeline**.

The Pipeline build strategy can be used to implement sophisticated workflows:

- continuous integration
- continuous deployment

The Pipeline build strategy allows developers to define a [Jenkins pipeline](https://jenkins.io/doc/pipeline/) for execution by the Jenkins pipeline plugin. The build can be started, monitored, and managed by OpenShift Container Platform in the same way as any other build type.

Pipeline workflows are defined in a Jenkinsfile, either embedded directly in the pipeline configuration, or supplied in a Git repository and referenced by the pipeline configuration.

## First pipeline

You should have access to a project called **cicd-[USER]**  , switch to this project via:

```bash
oc project cicd-[USER]
```

**[USER]** will have admin rights on project **cicd-[USER]**

In this project, there should be a route with name jenkins. Let's see what routes exist in the project:

```bash
$ oc get routes
NAME      HOST/PORT                                                   PATH      SERVICES   PORT      TERMINATION     WILDCARD
jenkins   jenkins-cicd-[USER].apps.cluster-centris-0c77.centris-0c77.example.opentlc.com             jenkins    <all>     edge/Redirect   None
```

Now copy the url from this route, in this case *jenkins-cicd-[USER].apps.cluster-centris-0c77.centris-0c77.example.opentlc.com* from the route definition and open this url in a browser. **!Replace the route url with what you get from your own execution**

The first time you hit a OpenShift Jenkins with a specific user, you will get an OpenShift authentifikation mask.

![Jenkins OAuth2 login](data/images/jenkins_oauth2_login.png "Jenkins OAuth2 Login")

After that you might get a Jenkins screen asking for authorization permissions.
See the image below.
![Jenkins OAuth2 permissions](data/images/jenkins_oauth2_permissions.png "Jenkins OAuth2 permissions")

Accept these and go to the next screen, by clicking on 'Alow selected permissions'.

Next screen, should be the famous/classical (or infamous) Jenkins welcome screen.

![Jenkins welcome](data/images/jenkins_welcome_screen.png "Jenkins welcome")

Background for that authentication workflow is that, Jenkins is making use of OpenShift's built-in OpenID Connect Identity Provider mechanism, that allows applications to delegate authentication to OpenShift and use the users provisioned into Openshift. This is very convenient for any kind of management application, where users of it are also users of OpenShift.

### Step 1

Now that we have confirmed Jenkins master is up and running, we can start creating a first pipeline. Openshift pipelines are just BuildConfig objects with a special strategy.

Let's create a folder for this hands-on:

```bash
mkdir pipelines
cd piplelines
```

Copy the content below and write it into a file called **bc_first-pipeline.yaml**

```yaml
apiVersion: v1
kind: BuildConfig
metadata:
  name: first-pipeline
spec:
  strategy:
    jenkinsPipelineStrategy:
      jenkinsfile: |-
        pipeline {
          stages {
            stage("Hello") {
              steps {
               sh 'echo "Hello World!"'
              }
            }
          }
        }
    type: JenkinsPipeline
  triggers: []
```

**Note:** The pipeline above is a declarative Jenkins pipeline. For seeing the differences between declarative vs scripting see [here](https://jenkins.io/doc/book/pipeline/syntax/#compare)

and let's create a resource based on this file on the cicd project.

```bash
oc apply -f bc_first-pipeline.yaml -n cicd-[USER]
```

**Note:** The command above creates the pipeline in CICD project. If the pipeline would be created in DEV stage then the cluster would try to provision a Jenkins master instance in the DEV stage. In the current step, a jenkins master should already be provisioned in the CICD project.

You can verify the applied buildconfig, by getting the list of buildconfigs:

```base
$ oc get buildconfig -n cicd-user200
NAME             TYPE              FROM   LATEST
first-pipeline   JenkinsPipeline          0

As soon as the pipeline is created, we can start it with the following command:

```bash
oc start-build first-pipeline -n cicd-[USER]
```

Now go to OpenShift web console (Developer mode) and go to pipelines view by clicking on Builds from the menu shown on left, see the image below:
![Pipeline link](data/images/console_pipeline_link.png "Pipeline link")

Then click on the BuildConfig with the name `first-pipeline` and select the Builds tab.\
You should see that first run/build of the pipeline has failed:
![Pipeline failed](data/images/failed_pipeline_agent.png "")

Now click on the build with the name `first-pipeline-1` and then click on the 'View Log' link, to jump to Jenkins build logs.
See the image below which highlights the 'View Log' link.

![Pipeline log link](data/images/view_pipeline_log.png "")

In this screen we have an error message which says 'agent section' is missing.

![jenkins_missing_agent_error.png](data/images/jenkins_missing_agent_error.png "")

Agent is a required field for a declarative pipeline, you can read [here](https://jenkins.io/doc/book/pipeline/syntax/#agent) for details.

Let's add the following section to our pipeline to set an agent. Do this inside the local file `bc_first-pipeline.yaml`.

```Groovy
          agent {
            label 'master'
          }
```

Pipeline part of the BuildConfig would look like this:

```Groovy
...
      jenkinsfile: |-
        pipeline {
          agent {
            label 'master'
          }
          stages {
            stage("Clone Source") {
              steps {
              sh 'echo "Hello World!"'
              }
            }
          }
        }
```

**Note:** It is also possible to change the pipeline inside the web console. Go to the build details page and select *Actions* -> *Edit Build Config* (on the top right corner).

Update the build resource configuration:

```bash
oc apply -f bc_first-pipeline.yaml -n cicd-[USER]
```

By setting the agent to the label 'master', we define that the pipeline steps should be executed in the jenkins master. After updating the pipeline, run the pipeline again.
Start the build by going again to the build details page of the web console. Select *Actions* -> *Start Build* (on the top right corner).\
This time it should finish successfully. See the image below for example output from a successful run:

![agent_successful_run_log.png](data/images/agent_successful_run_log.png "")

It's up to the Jenkins Pipeline author - you - to decide where each step of a Pipeline should be executed. Depending on what tools are used, you should select the right agent. For example, if you want to run a maven task, then maven should be available on the target agent where the maven step is executed.

### Step 2

Let's continue to extend our pipeline.

This time, we would like to checkout some source code and create a deployable artifact.
We will update the existing pipeline ( **first-pipeline** ) with the following pipeline definition.

**Note:** An easy way to change the pipeline is within the Jenkins gui. Go to the job `Jenkins -> cicd-[USER] -> cicd-[USER] -> first-pipeline` and click on Configure. Change the script in the Pipeline section. The new pipeline configuration will be synced back to the Build Config of the OpenShift CICD project.

```Groovy
pipeline {
  agent {
    label 'maven'
  }
  stages {
    stage("Clone Source") {
      steps {
        git 'https://git.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com/training/spring-boot-hello-world.git'
      }
    }

    stage("Mvn build"){
        steps{
            sh "mvn clean package -DskipTests"
        }
    }
  }
}
```

There are couple of things to notice here:

- As target agent instead of **master** , **maven** is used. This will cause a new pod to be scheduled to execute the maven steps, if there is no existing one.
- All the steps are executed on the agent that is specified at the pipeline level.
- There are two steps now. The first one is for checking out the source code. The second step, spawns a new shell to trigger maven goals.

Run the pipeline again. Either via oc cli ( oc start-build) or OpenShift Web Console or alternatively directly via the Jenkins UI. You will notice that Jenkins and Openshift will be consistent regarding Job definitions and status i.e. you can also start a Jenkins Job via the 'Build Now' button on Jenkins and the job run should synchronised a build back to OpenShift.

The cli command for starting a new build:

```bash
oc start-build first-pipeline
```

In order to see the creation of the new maven pod/slave/agent, the following command can be used:

```bash
oc get pods -w
```

example output:

```bash
NAME              READY     STATUS    RESTARTS   AGE
jenkins-1-dqzmg   1/1       Running   0          4h
maven-v8j2m   0/1       Pending   0         0s
maven-v8j2m   0/1       Pending   0         0s
maven-v8j2m   0/1       ContainerCreating   0         0s
maven-v8j2m   1/1       Running   0         5s
maven-v8j2m   0/1       Terminating   0         1m
maven-v8j2m   0/1       Terminating   0         1m
maven-v8j2m   0/1       Terminating   0         1m
```

**Note:** After build was complete the newly created maven pod (*maven-v8j2m* in the example above) got terminated.
The behavior of how long a slave/agent pod stays around is controlled via Jenkins. Click on 'Manage Jenkins' on main Jenkins Screen, go to 'Configure System' search for 'Time in minutes to retain slave when idle', enter a value for this field if you want to keep slaves around even when they are not in use.

Check the build job logs again. This time you should see from the logs that maven ran and it downloaded pretty much the whole internet :)
Example logs tail:

```bash
[INFO] Installing /tmp/workspace/cicd-user2/cicd-user2-first-pipeline/target/spring-boot-hello-world-0.1.0.jar to /home/jenkins/.m2/repository/com/appuio/techlab/spring-boot-hello-world/0.1.0/spring-boot-hello-world-0.1.0.jar
[INFO] Installing /tmp/workspace/cicd-user2/cicd-user2-first-pipeline/pom.xml to /home/jenkins/.m2/repository/com/appuio/techlab/spring-boot-hello-world/0.1.0/spring-boot-hello-world-0.1.0.pom
[INFO] [1m------------------------------------------------------------------------[m
[INFO] [1;32mBUILD SUCCESS[m
[INFO] [1m------------------------------------------------------------------------[m
[INFO] Total time: 57.224 s
[INFO] Finished at: 2019-04-18T11:44:16Z
[INFO] Final Memory: 34M/146M
[INFO] [1m------------------------------------------------------------------------[m
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
```

A jar artifact is ready to be used within a container.

**Note:** For increasing build speed, more memory/cpu can be provided to slave pod.

**Note:** To persist (and thus to avoid download) dependencies through different job runs, see [Slaves with PVs](#slaves-with-PVs)

### Step 3

We have 4 OpenShift projects for each user:

- cicd-[USER] : Jenkins and slaves
- app-dev-[USER]: Stage development
- app-int-[USER]: Stage integration
- app-prod-[USER]: Stage production

Now that there is an artifact, namely a jar file that we would like to run, we need to create a container image from this jar file. A docker build with binary input seems appropriate for the job. We should build a container image in the **DEV** stage. So Use the following commands to create a bc, dc, service and route:

```bash
oc project app-dev-[USER]
oc new-build java --name=spring-app --binary=true
oc new-app spring-app --allow-missing-imagestream-tags --labels=app=spring-app
oc set probe dc/spring-app --readiness --get-url=http://:8080/hello --failure-threshold=3 --initial-delay-seconds=10 --period-seconds=10 --success-threshold=1 --timeout-seconds=30
oc create service clusterip spring-app --tcp=8080:8080
oc expose svc/spring-app
```

After having prepared the application on Dev stage, the pipeline can be updated with the following content:

```bash
pipeline {
  agent {
    label 'maven'
  }

  environment {
    app = "spring-app"
    devProject = 'app-dev-[USER]'
  }

  stages {
    stage("Clone Source") {
      steps {
        git 'https://git.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com/training/spring-boot-hello-world.git'
      }
    }

    stage("Mvn build"){
        steps{
            sh "mvn clean install -DskipTests"
            sh "mv target/*.jar target/artifact.jar"
        }
    }

    stage('Build image on Openshift') {
      steps {
        script {
          openshift.withCluster() {
            openshift.withProject("${devProject}") {
              println "Building latest on bc:${app} on project:${devProject}"
              openshift.selector("bc", app).startBuild("--from-file=target/artifact.jar", "--wait")
            }
          }
        }
      }
    }
  }
}
```

**Important**: Adapt the environment section of the pipeline to your concrete setup and user number.

Start the pipeline again and see that it fails with a message like:

```bash
ERROR: Error running start-build on at least one item: [buildconfig/spring-app];
{reference={}, err=Uploading file "target/artifact.jar" as binary input for the build ...

Uploading finished
Error from server (Forbidden): buildconfigs.build.openshift.io "spring-app" is forbidden: User "system:serviceaccount:cicd-[USER]:jenkins" cannot create buildconfigs.build.openshift.io/instantiatebinary in the namespace "app-dev-user42": no RBAC policy matched, verb=start-build, cmd=oc --server=https://172.30.0.1:443 --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt --namespace=app-dev-[USER] --token=XXXXX start-build buildconfig/spring-app --from-file=target/artifact.jar --wait -o=name , out=, status=1}

Finished: FAILURE
```

The reason for this failure is that, CICD project service account which jenkins slave runs with, does not have the right permissions on the target project i.e. DEV in this case. Assign the correct permissions by using `oc policy add-role-to-user` command. *Edit* role should suffice for enabling Jenkins in this particular case.

Example command:

```bash
oc policy add-role-to-user edit system:serviceaccount:cicd-[USER]:jenkins -n app-dev-[USER]
```

This command creates a rolebinding in the project `app-dev-[USER]` for the edit role and includes the serviceaccount jenkins from the project `cicd-[USER]` in it.

This is reflected in the edit RoleBinding of your dev project:

```bash
oc describe rolebinding edit -n app-dev-[USER]
```

Another approach is to add the token of a ServiceAccount in the target project to the tokens of the jenkins ServiceAccount, so it is able to access the target Project. See [documentation](https://docs.openshift.com/container-platform/4.3/openshift_images/using_images/images-other-jenkins.html#images-other-jenkins-cross-project_images-other-jenkins) for details.

Run the build again and this time build should succeed. The new build should also trigger a new deployment. Verify that the latest deployment has run successfully and there is a pod running for the application.

### Step 4

Next step is to tag the image that was just built, but before that, let's trigger a new deployment and add a simple test to verify that software works as expected.

When we manage the deployment of the application from a pipeline, we have to remove the OpenShift triggers, otherwise new deployments would be immediately triggered:

```bash
oc patch dc/spring-app -p '{"spec":{"triggers":[]}}' -n app-dev-[USER]
```

Embed the *step* below into the pipeline to add a simple testing mechanism. A simple curl call is made and its HTTP return status code is checked after having a deployed the latest version of the app.
Add the code snippet shown below **after** the last stage of the pipeline.

```Groovy
    stage('Functional tests') {
      steps {
        script {
          openshift.withCluster() {
            openshift.withProject("${devProject}") {
              openshift.selector("dc", app).rollout().latest()
              def latestDeploymentVersion = openshift.selector('dc',app).object().status.latestVersion
              def rc = openshift.selector('rc', "${app}-${latestDeploymentVersion}")
              timeout (time: 2, unit: 'MINUTES') {
                  rc.untilEach(1){
                      def rcMap = it.object()
                      return (rcMap.status.replicas.equals(rcMap.status.readyReplicas))
                  }
              }
              def route= sh( script:'oc get route '+app+' -ocustom-columns=host:{.spec.host} --no-headers -n' +devProject ,returnStdout: true)
              println("Calling route:${route}")
              def httpCode = sh(script:'curl -s -o /dev/null -w "%{http_code}" ' + route,returnStdout: true)
              if(httpCode!="200"){
                throw new Exception("Curl failed, HttpStatus:${httpCode}")
              }
            }
          }
        }
      }
    }
```

After that the container image can be seen as tested and ready to be tagged, so we can later consume particular tags based on a specific build.

The next snippets set up the tagging of images. There will be two tags added to the image. One is based on the version derived from the pom and Jenkins Build Job number.
The other one is based short git hash.

Add code shown below to the end of pipeline.

First, add a function to the end of the pipeline (after closing curly brackets).

```Groovy
def getVersionFromPom(pom) {
  def matcher = readFile(pom) =~ '<version>(.+)</version>'
  def version= matcher ? matcher[0][1] : null
  if(version.endsWith('.RELEASE')){
    version = version.substring(0,version.lastIndexOf('.'))
  }
  return version
}
```

Add a new stage (the last one) for tagging with code below:

```Groovy
    stage('Tag image'){
      steps{
        script{

          version=getVersionFromPom('pom.xml')+"${BUILD_NUMBER}" // BUILD_NUMBER variable comes from Jenkins Job
          def gitHash= sh(script:'git rev-parse --short HEAD' ,returnStdout: true)
          openshift.withCluster() {
            openshift.withProject(devProject) {
              openshift.tag("${app}:latest", "${app}:${version}")
              openshift.tag("${app}:latest", "${app}:${gitHash}")
            }
          }
        }
      }
    }
```

You can always test and execute the BuildConfig and see how the individual builds perform.

### Step 5: Templates

Now that Dev stage is ready, the build is running, a testing deployment suceeded and images have been tagged for later consumption, we are ready to promote the content. For that we are going to create OpenShift objects for next stages.

For that we can use a template, which is saved in a file in the techlab repository called *labs/data/pipelines/template_spring-app.yml*. This eases creating all the OpenShift objects that make up the application in other projects/namespaces.

OpenShift templating is a simple yet powerful abstraction. To learn more about it, see [here](https://docs.openshift.com/container-platform/4.3/openshift_images/using-templates.html). For general templating options see [here](extras/templating.md).

One important thing to notice here is that, BuildConfig is not included in the template. Reason for that is, our goal is to use the same container image that is already built (Image Promotion). That means, integration and production stages need to pull container image from development stage. Commands below assign the correct permissions for int and prod stages on the dev stage:

```bash
oc policy add-role-to-user system:image-puller system:serviceaccount:app-prod-[USER]:default --namespace=app-dev-[USER]

oc policy add-role-to-user system:image-puller system:serviceaccount:app-int-[USER]:default --namespace=app-dev-[USER]
```

These commands allow the ServiceAccount deploying the application (and thus pulling the images) called `default` in the int and prod namespaces to pull images from the dev namespace. The dev namespace is where we push our images to from the pipeline.


With the following command, Openshift objects required for the application can be created on both INT and PROD stages using the template:

```bash
wget https://git.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com/training/techlab/raw/master/labs/data/pipelines/template_spring-app.yml -O template_spring-app.yml
for ns in 'app-int-[USER]' 'app-prod-[USER]';do oc process -f template_spring-app.yml DEV_PROJECT=app-dev-[USER] | oc apply -f - -n "$ns";done
```

**Important**: Make sure you adapt the parameter `DEV_PROJECT` to your development project, as this is from where the images will be fetched. See the template how the parameter is being used.

### Step 6

It's time to deploy to non-DEV stages. For that we will create a deployment pipeline in Jenkins. Create a new pipeline by clicking on 'New Item' on the main Jenkins screen inside the cicd-[USER] folder and name it `deployment`. In this new screen, select the 'Pipeline' type and create a pipeline based on the code below.

By the way, you might run into couple of issues when running this new pipeline. Using what you've learned in the previous steps, you should be able to solve them.

```Groovy
def app = 'spring-app'
def devProject = 'app-dev-[USER]'
def intProject = 'app-int-[USER]'
def prodProject = 'app-prod-[USER]'
def project = ''
def imageTag = ''

properties([
        parameters([
                choice(choices: "integration\nproduction", description: 'Stage, which will be checked out.', name: 'STAGE'),
                       string(name: 'TAG', defaultValue: '', description: 'Image tag to use for deployment (e.g. latest)')

        ])
])

switch ("${params.STAGE}") {
    case "integration":
        project = intProject
        break

    case "production":
        project = prodProject
        break

    default:
        project = ''
}

if (project == '') {
    currentBuild.result = 'ABORTED'
    error('No valid project selected ...')
}

imageTag = params.TAG

if(!imageTag){
    currentBuild.result = 'ABORTED'
    error('No tag entered...')
}

pipeline {
    agent {
        label 'master'
    }

    stages {
        stage('Change image stream') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(project) {
                            latestDeploy = openshift.selector('dc', app).object()
                            latestDeploy.spec.template.spec.containers[0].image="image-registry.openshift-image-registry.svc:5000/${devProject}/${app}:${imageTag}"
                            openshift.apply(latestDeploy)
                        }
                    }
                }
            }
        }

        stage('Deploy image') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject(project) {
                            openshift.selector("dc", app).rollout().latest()
                            timeout(3) {
                                def latestDeploymentVersion = openshift.selector('dc', app).object().status.latestVersion
                                def rc = openshift.selector('rc', "${app}-${latestDeploymentVersion}")
                                rc.untilEach(1) {
                                    def rcMap = it.object()
                                    return (rcMap.status.replicas.equals(rcMap.status.readyReplicas))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
```

If you create a pipeline in OpenShift, it will automatically get synced with Jenkins and back. When a pipeline is created directly on Jenkins however, it will not appear under OpenShift pipelines automatically. Thus this deployment pipeline will only be available in Jenkins.

In general it is recommended that you put your Pipelines and Jenkis configuration also into git.

Once you have successfully configured your Pipeline, you are able to deploy an image tag into a specific stage by executing a `Buuild with Parameters`.

### Step X

Now that you know the basic knowhow about using Jenkins on OpenShift you might want to put everything together into one pipeline and even tackle more complex scenarios.

#### A/B deployments

The A/B deployment strategy lets you try a new version of the application in a limited way in the production environment. You can specify that the production version gets most of the user requests while a limited fraction of requests go to the new version. Since you control the portion of requests to each version, as testing progresses you can increase the fraction of requests to the new version and ultimately stop using the previous version.  See [here](https://docs.openshift.com/container-platform/4.3/applications/deployments/route-based-deployment-strategies.html#deployments-ab-testing_route-based-deployment-strategies) for more details.

In a nutshell: Have 2 deploymentconfigs which use different versions of container images and have 2 services each of which points to a specific deploymentconfig. Read [this link](https://docs.openshift.com/container-platform/4.3/applications/deployments/route-based-deployment-strategies.html#deployments-ab-testing-lb_route-based-deployment-strategies) to see how you can loadbalance incoming traffic to different services.

#### Blue / Green deployments

Martin Fowler defines Blue/Green deployments so:
>One of the challenges with automating deployment is the cut-over itself, taking software from the final stage of testing to live production. You usually need to do this quickly in order to minimise downtime. The blue-green deployment approach does this by ensuring you have two production environments, as identical as possible. At any time one of them, let's say blue for the example, is live. As you prepare a new release of your software you do your final stage of testing in the green environment. Once the software is working in the green environment, you switch the router so that all incoming requests go to the green environment - the blue one is now idle.

Thanks to abstractions offered, blue/green deployments are pretty straightforward on OpenShift.
See [here](https://docs.openshift.com/container-platform/4.3/applications/deployments/route-based-deployment-strategies.html#deployments-blue-green_route-based-deployment-strategies) for OpenShift's take on it.

And [here](https://git.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com/training/techlab/src/master/labs/data/pipelines/Jenkinsfile) is an example blue/green pipeline.

Go ahead and see if you can implement a pipeline for blue/greed deployment yourself.

## General tips and tricks

### Slaves with PVs

Jenkins slaves which run as Pods are by default stateless i.e. if there are artifacts or other binaries that you would like to keep even when a Pod gets restarted, Persistent Volumes should be used. Make sure that artifact folder used by maven is on the persistent volume. To force maven to use a specific folder,  you can configure mvn on the fly via: ```mvn -Dmaven.repo.local=$HOME/.my/other/repository clean install``` or via  the *setting.xml* file.

### Slave retention/idle time

Jenkins slave that are created on demand will be terminated after they are done building jobs and sometimes you want to keep slaves around even when they are not doing any work so that you don't need to wait until a slave is created and registered on Jenkins master. The retention policy and  setting ***Time in minutes to retain agent when idle*** which is listed under 'Kubernetes Pod Template', can be used to control how long you keep unused/idle slaves around.

![Slave Pod retention](data/images/pod_retention.png "Slave Pod retention")

### OpenShift Jenkins Sync

[Openshift-jenkins-sync-plugin](https://github.com/openshift/jenkins-sync-plugin/blob/master/README.md) can sync objects such as Secrets,ConfigMaps from OpenShift projects onto Jenkins. This is a very powerful feature and it's also the main enabler of pipeline strategy builds. One typical use case is to keep credentials such git ssh keys as secrets and have Jenkins sync them so that these credentials can be used in build jobs.

For syncing secrets make sure that secrets are labeled accordingly. E.g. :```oc label secret jboss-eap-quickstarts-github-key credential.sync.jenkins.openshift.io=true```

### OpenShift Client Plugins

Jenkins slaves/masters can run on one cluster and they can interact with other clusters. See [jenkins-client-plugin](https://github.com/openshift/jenkins-client-plugin) for details.
In order to address multiple clusters, first configure them on Jenkins via *Manage Jenkins-> Configure Systems->OpenShift Jenkins Sync* as shown in image below.
![Jenkins sync plugin](data/images/jenkins_sync.png "Jenkins sync plugin")

Using the declarative pipeline, specific clusters can be targeted using `openshift.withCluster` notation.

### Openshift rights

All pods on OpenShift run with a ServiceAccount and the service account that 'runs' a job should have the rights set up according to what actions it aims to execute on the target namespace/project.

```bash
oc policy add-role-to-user edit system:serviceaccount:$CICD_PROJECT:$SA -n $TARGET_PROJECT


$CICD_PROJECT is the OpenShift project on which Jenkins job runs.
$SA sets the service account which runs the Jenkins job.
$TARGET_PROJECT is where OpenShift object you interact with resides on.
```
