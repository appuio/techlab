# OpenShift Pipelines

Mit OpenShift Pipelines hat man die Möglichkeit komplexe CI/CD Prozesse voll integriert abzubilden. In diesem Lab zeigen wir, wie man mit OpenShift Pipelines arbeitet und so Applikationen buildet, tested und entsprechend kontrolliert in die verschiedenen Stages promoted.

https://docs.openshift.com/container-platform/3.9/dev_guide/dev_tutorials/openshift_pipeline.html

## Grundprinzip

OpenShift Pipelines basieren auf Jenkins Pipelines, welche voll integriert mit OpenShift fungieren. So hat man BuildConfigs vom Typ `jenkinsPipelineStrategy` anzulegen, welche wieder eine Jenkins Pipeline referenzieren.


## LAB: Eine einfache OpenShift Pipeline Anlegen und ausführen.

Um zu verstehen wie OpenShift Pipelines funktionieren wollen wir als ersten Schritt direkt eine Pipeline anlegen.

Erstellen wir dafür ein neues Projekt `oc new-project [USER]-buildpipeline`

Wir legen mit folgendem Befehl die entsprechende BuildConfig an, welche als Input auf das JenkinsFile in einem Gitrepository https://github.com/appuio/simple-openshift-pipeline-example.git verweist.

```bash
$ oc create -f ./additional-labs/resources/simple-openshift-pipeline.yaml
```

Auf Grund der BuildConfig deployt OpenShift automatisch einen integrierten Jenkins und führt die definierte Jenkins Pipeline darin aus.
In unserem Beispiel lediglich eine Testpipeline, jedoch bieten Jenkins Pipelines volle Flexiblität um komplexe CI/CD Pipelines abzubilden.

```
node {
    stage('Build') {
        echo "Build"
	sleep 5
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

## BuildConfig Optionen
Im vorherigen Lab haben wir der BuildConfig vom Typ `jenkinsPipelineStrategy` ein Git Repository als Source für das JenkinsFile angegeben. Als Alternative dazu kann das Jenkins Pipeline File auch direkt in der BuildConfig hinterlegt werden.

```yaml
kind: "BuildConfig"
apiVersion: "v1"
metadata:
  name: "appuio-sample-pipeline"
spec:
  strategy:
    jenkinsPipelineStrategy:
      jenkinsfile: |-
        node {
            stage('Build') {
                echo "Build"
            sleep 5
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

## Jenkins OpenShift Plugins

Der durch OpenShift dynamisch deployte Jenkins, ist durch das OpenShift Plugin vollständig mit OpenShift gekoppelt. Einerseits kann so direkt auf Resourcen innerhalb des Projekts zugegriffen werden, andererseits können durch entsprechendes Labeling dynamische Slaves aufgesetzt werden.

Zusäztliche Informationen finden Sie hier: https://docs.openshift.com/container-platform/3.9/install_config/configuring_pipeline_execution.html#openshift-jenkins-client-plugin

### OpenShift Jenkins Pipeline

Mit dem OpenShift Jenkins Pipeline Plugin kann so auf einfach Art direkt mit dem OpenShift Cluster kommuniziert werden:

```
openshift.withCluster( 'https://10.13.137.207:8443', 'CO8wPaLV2M2yC_jrm00hCmaz5Jgw...' ) {
    openshift.withProject( 'myproject' ) {
        echo "Hello from project ${openshift.project()} in cluster ${openshift.cluster()}"
    }
}
```
weitere Informationen dazu sind unter https://github.com/openshift/jenkins-client-plugin/blob/master/README.md zu finden.

### OpenShift Jenkins Sync Plugin

Das OpenShift Jenkins Sync Plugin synchronisiert BuildConfig und Jenkins Jobs synchron. Des Weiteren erlaubt es das dynamische erstellen und definieren von Jenkins Slaves via Imagestream

### Custom Slaves

Custom Jenkins Slaves können einfach in den Build integriert werden, dafür müssen die entsprechenden Slaves als Imagestreams angelegt und mit dem label `role=jenkins-slave` versehen werden. Diese werden dann automatisch als Pop Templates im Jenkins registriert. So können Pipelines nun über `node ('customslave'){ ... }` teile ihrer Builds auf den entsprechenden Custom Slaves laufen lassen.