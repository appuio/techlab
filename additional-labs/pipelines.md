# OpenShift Pipelines

Mit OpenShift Pipelines hat man die Möglichkeit komplexe CI/CD Prozesse voll integriert abzubilden. In diesem Lab zeigen wir, wie man mit OpenShift Pipelines arbeitet und so Applikationen buildet, tested und entsprechend kontrolliert in die verschiedenen Stages promoted.

https://docs.openshift.com/container-platform/3.9/dev_guide/dev_tutorials/openshift_pipeline.html

## Grundprinzip

OpenShift Pipelines basieren auf Jenkins Pipelines, welche voll integriert mit OpenShift fungieren. So hat man BuildConfigs vom Typ `jenkinsPipelineStrategy` anzulegen, welche wieder eine Jenkins Pipeline referenzieren.


## LAB: Eine einfache OpenShift Pipeline anlegen und ausführen.

Um zu verstehen wie OpenShift Pipelines funktionieren wollen wir als ersten Schritt direkt eine Pipeline anlegen.

Erstellen wir dafür ein neues Projekt `oc new-project [USER]-buildpipeline`

Wir legen mit folgendem Befehl die entsprechende BuildConfig an, welche das JenkinsFile also die Pipeline direkt beinhaltet. Ebenso wird ein zweite BuildConfig angestosse, diese enthält die Docker BuildConfig für die eigentliche Applikation die wir im Rahmen dieser Pipeline deployen wollen, im vorliegenden Beispiel eine simple PHP Applikation

```bash
$ oc create -f ./additional-labs/resources/simple-openshift-pipeline.yaml
```

Auf Grund der BuildConfig deployt OpenShift automatisch eine integrierte Jenkins Instanz. Schauen wir uns dies in der Web Console an. Im Projekt befindet sich nach erfolgreichem Deployment eine laufende Jenkins Instanz, welche über eine Route exposed ist. Der Zugriff auf den Jenkins über die Route ist mittles OpenShift Oauth gesichert, loggen Sie dort ein und erteilen Sie entsprechende Rechte. Ebenso wurde die vorher angelegte Build Pipeline synchronisiert und automatisch angelegt.

![Jenkins Overview](../images/pipeline-jenkins-overview.png)

Nebst der erstellten Build Pipeline wurde auch die OpenShift Sample Pipeline angelegt.

Zurück in der OpenShift Web Console können wir nun über Builds --> Pipelines die Pipeline starten.

![Start Pipeline](../images/openshift-pipeline-start.png)

Dabei wird von OpenShift der Jenkins Job gestartet und entsprechend in die Pipeline Ansicht synchronisiert.

![Run Pipeline](../images/openshift-pipeline-run.png)
![Run Pipeline Jenkins](../images/openshift-pipeline-jenkins-view-run.png)


Unser Beispiel hier enthält Testpipeline, die das generelle Prinzip veranschaulicht, jedoch bieten Jenkins Pipelines volle Flexiblität um komplexe CI/CD Pipelines abzubilden.

```groovy
def project=""
node {
    stage('Init') {
        project = env.PROJECT_NAME
    }
    stage('Build') {
        echo "Build"
        openshift.withCluster() {
            openshift.withProject() {
                def builds = openshift.startBuild("application"); 
                builds.logs('-f')
                timeout(5) {
                    builds.untilEach(1) {
                    return (it.object().status.phase == "Complete")
                    }
                }
            }
        }
    }
    stage('Test') {
        echo "Test"
        sleep 2
    }
}
node ('maven') {    
    stage('DeployDev') {
        echo "Deploy to Dev"
        sleep 5
    }
    stage('PromoteTest') {
        echo "Deploy to Test"
        sleep 5
    }
    stage('PromoteProd') {
        echo "Deploy to Prod"
        sleep 5
    }
}
```

Die Testpipeline besteht aus sechs Pipeline-Stages, welche auf zwei Jenkins Slaves ausgeführt werden. Die `Build` Pipeline-Stage, ist aktuell die einzig ausprogrammierte Stage. Sie startet nähmlich im Projekt den Docker Build für unsere Applikation und wartet entsprechend bis dies erfolgreich abgeschlososen ist.

Die letzten drei Steps werden bedingt durch den node selector `node ('maven') { ... }` auf einem Jenkins Slave mit dem Namen `maven` ausgeführt. Dabei startet OpenShift mittels Kubernetes Plugin dynamisch einen Jenkins Slave Pod und führt entsprechend diese Stages auf diesem Slave aus. 

Der `maven` Slave ist im Kubernetes Plugin vorkonfiguriert und die Pipeline-Stages auf dem Slave `registry.access.redhat.com/openshift3/jenkins-slave-maven-rhel7:v3.7` ausgeführt. Weiter unten im Kapitel zu Custom Slaves werden Sie lernen, wie man individuelle Slaves dazu verwendet um Pipelines darauf auszuführen.

## BuildConfig Optionen

Im vorherigen Lab haben wir der BuildConfig vom Typ `jenkinsPipelineStrategy` das JenkinsFile direkt angegeben. Als Alternative dazu kann das Jenkins Pipeline File auch via GitRepository in der BuildConfig hinterlegt werden.

```yaml
kind: "BuildConfig"
apiVersion: "v1"
metadata:
  name: "appuio-sample-pipeline"
spec:
  source:
    git:
      uri: "https://github.com/appuio/simple-openshift-pipeline-example.git"
  strategy:
    jenkinsPipelineStrategy:
      jenkinsfilePath: Jenkinsfile

```

## Jenkins OpenShift Plugins

Der durch OpenShift dynamisch deployte Jenkins, ist durch das OpenShift Plugin vollständig mit OpenShift gekoppelt. Einerseits kann so direkt auf Resourcen innerhalb des Projekts zugegriffen werden, andererseits können durch entsprechendes Labeling dynamische Slaves aufgesetzt werden.

Zusäztliche Informationen finden Sie hier: https://docs.openshift.com/container-platform/3.9/install_config/configuring_pipeline_execution.html#openshift-jenkins-client-plugin

### OpenShift Jenkins Pipeline

Mit dem OpenShift Jenkins Client Plugin kann so auf einfach Art direkt mit dem OpenShift Cluster kommuniziert werden und entsprechend als Jenkinsfile komplexe Ci/CD Pipelines implementieren:

```
openshift.withCluster() {
    openshift.withProject() {
        echo "Hello from project ${openshift.project()} in cluster ${openshift.cluster()}"
    }
}
```
weitere Informationen dazu sind unter https://github.com/openshift/jenkins-client-plugin/blob/master/README.md zu finden.

Zusätlich zum Client Plugin existiert das vorgänger Plugin (Jenkins Pipeline Plugin), welches weniger Funktionalität bietet, allerdings gemäss https://docs.openshift.com/container-platform/3.9/using_images/other_images/jenkins.html#pipeline-plug-in supportet bleibt.

### OpenShift Jenkins Sync Plugin

Das OpenShift Jenkins Sync Plugin hält BuildConfig und Jenkins Jobs synchron. Des Weiteren erlaubt es das dynamische erstellen und definieren von Jenkins Slaves via Imagestream.

### Kubernetes Plugin

Das Kubernetes Plugin wird verwendet um die Jenkins Slaves dynamisch im OpenShift Projekt zu starten. 

### Custom Slaves

Custom Jenkins Slaves können einfach in den Build integriert werden, dafür müssen die entsprechenden Slaves als Imagestreams angelegt und mit dem label `role=jenkins-slave` versehen werden. Diese werden dann automatisch als Pod Templates im Jenkins für das Kubernetes Plugin registriert. So können Pipelines nun über `node ('customslave'){ ... }` Teile ihrer Builds auf den entsprechenden Custom Slaves laufen lassen.

#### LAB: Custom Jenkins Slave als Build Slave verwenden

TODO

## LAB: Multi Stage Deployment

Als nächstes wollen wir nun unsere Pipeline weiter ausbauen und das Deployment der Applikation auf den unterschiedlichen Stages (dev, test, prod) angehen

Für ein Multi Stage Deployment auf OpenShift hat sich das folgende Setup als Bestpractice erwiesen.

* Ein Build Projekt, CI/CD Umgebung Jenkins, Docker Builds, S2I Builds ...
* Pro Stage (dev, test, ..., prod) ein Projekt, welche die laufenden Pods und Services enthält.

Das Build Projekt haben wir oben bereits eingerichtet `[USER]-buildpipeline` als nächsten Schritt erstellen wir nun die Projekte für die unterschiedlichen Stages

* `oc new-project [USER]-pipeline-dev`
* `oc new-project [USER]-pipeline-test`
* `oc new-project [USER]-pipeline-prod`

Nun müssen wir den `puller` Service Accounts aus den entsprechenden Projekten für die Stage die nötigen Rechte geben, damit die gebuildeten Images gepullt werden können.

```bash
oc policy add-role-to-group system:image-puller system:serviceaccounts:[USER]-pipeline-dev -n [USER]-buildpipeline
oc policy add-role-to-group system:image-puller system:serviceaccounts:[USER]-pipeline-test -n [USER]-buildpipeline
oc policy add-role-to-group system:image-puller system:serviceaccounts:[USER]-pipeline-prod -n [USER]-buildpipeline
```

TODO: Berechtigungen um aus dem Builder Projekt deployments zu triggern.

Als nächstes erstellen wir in den entsprechenden Stage Projekten die Applikationen, dafür definieren wir einen Tag im Imagestream, welcher deployt werden soll.

* dev `oc new-app [USER]-buildpipeline/application:dev -n [USER]-pipeline-dev`
* test `oc new-app [USER]-buildpipeline/application:test -n [USER]-pipeline-test` 
* prod `oc new-app [USER]-buildpipeline/application:prod -n [USER]-pipeline-prod` 

In der Pipeline können wir nun mittels setzen des entsprechenden Tags auf dem Imagestream der gebuildeten Applikatoin bspw. `application:dev` das entsprechende Image in die passende Stage promoten und mittels Deployment die entsprechende Version deployen.

Passen sie ihre Pipeline entweder in der Web Console oder in der BuildConfig wie folgt an (die Werte für die Variablen `dev_project`, `test_project`, `prod_project` entsprechend setzen):

```groovy
def project=""
def dev_project="[USER]-pipeline-dev"
def test_project="[USER]-pipeline-test"
def prod_project="[USER]-pipeline-prod"
node {
    stage('Init') {
        project = env.PROJECT_NAME
    }
    stage('Build') {
        echo "Build"
        openshift.withCluster() {
            openshift.withProject() {
                def builds = openshift.startBuild("application")
                builds.logs('-f')
                timeout(5) {
                    builds.untilEach(1) {
                    return (it.object().status.phase == "Complete")
                    }
                }
            }
        }
    }
    stage('Test') {
        echo "Test"
        sleep 2
    }
}
node ('maven') {
    stage('DeployDev') {
        echo "Deploy to Dev"
        openshift.withCluster() {
            openshift.withProject() {
                # Tag the latest image to be used in dev stage
                openshift.tag("$project/application:latest", "$project/application:dev")
            }
            openshift.withProject($dev_project) {
                # trigger Deployment in dev project
                def dc = openshift.selector('dc', "application")
                dc.rollout().status()
            }
        }
    }
    stage('PromoteTest') {
        echo "Deploy to Test"
        openshift.withCluster() {
            openshift.withProject() {
                # Tag the dev image to be used in test stage
                openshift.tag("$project/application:dev", "$project/application:test")
            }
            openshift.withProject($test_project) {
                # trigger Deployment in test project
                def dc = openshift.selector('dc', "application")
                dc.rollout().status()
            }
        }
    }
    stage('PromoteProd') {
        echo "Deploy to Prod"
        openshift.withCluster() {
            openshift.withProject() {
                # Tag the test image to be used in prod stage
                openshift.tag("$project/application:test", "$project/application:prod")
            }
            openshift.withProject($prod_project) {
                # trigger Deployment in prod project
                def dc = openshift.selector('dc', "application")
                dc.rollout().status()
            }
        }
    }
}
```

Führen Sie die Pipeline erneut aus und schauen Sie sich an, wie nun die gebuildete Applikation von Stage zu Stage deployt wird.

## Jenkins Pipeline Sprache

Unter https://github.com/puzzle/jenkins-techlab finden Sie ein entsprechendes Hands-on Lab zur Jenkins Pipeline Sprache. Die Syntax ist [hier](https://jenkins.io/doc/book/pipeline/syntax/) beschrieben