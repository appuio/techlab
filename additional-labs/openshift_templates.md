## OpenShift templates

### Enter OpenShift templates
OpenShift comes out of the box with simple templating capabilities.
If you want to see what example templates look like, just run:
```oc get templates -n openshift```

and then select an example template from the result of the previous command run and then run:

```oc get template jws31-tomcat8-https-s2i -o yaml -n openshift```

(in this example I picked the template *jws31-tomcat8-https-s2i*)

and the content of the template is the following:

```
apiVersion: template.openshift.io/v1
kind: Template
labels:
  template: jws31-tomcat8-https-s2i
  xpaas: 1.4.16
message: A new JWS application for Apache Tomcat 8 has been created in your project.
  The username/password for administering your JWS is ${JWS_ADMIN_USERNAME}/${JWS_ADMIN_PASSWORD}.
  Please be sure to create the secret named "${JWS_HTTPS_SECRET}" containing the ${JWS_HTTPS_CERTIFICATE}
  file used for serving secure content.
metadata:
  annotations:
    description: An example JBoss Web Server application. For more information about
      using this template, see https://github.com/jboss-openshift/application-templates.
    iconClass: icon-rh-tomcat
    openshift.io/display-name: JBoss Web Server 3.1 Apache Tomcat 8 (with https)
    openshift.io/provider-display-name: Red Hat, Inc.
    tags: tomcat,tomcat8,java,jboss,hidden
    template.openshift.io/documentation-url: https://access.redhat.com/documentation/en/red-hat-jboss-web-server/
    template.openshift.io/long-description: This template defines resources needed
      to develop Red Hat JBoss Web Server 3.1 Apache Tomcat 8 based application, including
      a build configuration, application deployment configuration, and secure communication
      using https.
    template.openshift.io/support-url: https://access.redhat.com
    version: 1.4.16
  creationTimestamp: 2018-11-21T08:21:02Z
  name: jws31-tomcat8-https-s2i
  namespace: openshift
  resourceVersion: "2991443378"
  selfLink: /apis/template.openshift.io/v1/namespaces/openshift/templates/jws31-tomcat8-https-s2i
  uid: 625873cc-ed66-11e8-9dcc-0a2a2b777307
objects:
- apiVersion: v1
  kind: Service
  metadata:
    annotations:
      description: The web server's http port.
    labels:
      application: ${APPLICATION_NAME}
    name: ${APPLICATION_NAME}
  spec:
    ports:
    - port: 8080
      targetPort: 8080
    selector:
      deploymentConfig: ${APPLICATION_NAME}
- apiVersion: v1
  kind: Service
  metadata:
    annotations:
      description: The web server's https port.
    labels:
      application: ${APPLICATION_NAME}
    name: secure-${APPLICATION_NAME}
  spec:
    ports:
    - port: 8443
      targetPort: 8443
    selector:
      deploymentConfig: ${APPLICATION_NAME}
- apiVersion: v1
  id: ${APPLICATION_NAME}-http
  kind: Route
  metadata:
    annotations:
      description: Route for application's http service.
    labels:
      application: ${APPLICATION_NAME}
    name: ${APPLICATION_NAME}
  spec:
    host: ${HOSTNAME_HTTP}
    to:
      name: ${APPLICATION_NAME}
- apiVersion: v1
  id: ${APPLICATION_NAME}-https
  kind: Route
  metadata:
    annotations:
      description: Route for application's https service.
    labels:
      application: ${APPLICATION_NAME}
    name: secure-${APPLICATION_NAME}
  spec:
    host: ${HOSTNAME_HTTPS}
    tls:
      termination: passthrough
    to:
      name: secure-${APPLICATION_NAME}
- apiVersion: v1
  kind: ImageStream
  metadata:
    labels:
      application: ${APPLICATION_NAME}
    name: ${APPLICATION_NAME}
- apiVersion: v1
  kind: BuildConfig
  metadata:
    labels:
      application: ${APPLICATION_NAME}
    name: ${APPLICATION_NAME}
  spec:
    output:
      to:
        kind: ImageStreamTag
        name: ${APPLICATION_NAME}:latest
    source:
      contextDir: ${CONTEXT_DIR}
      git:
        ref: ${SOURCE_REPOSITORY_REF}
        uri: ${SOURCE_REPOSITORY_URL}
      type: Git
    strategy:
      sourceStrategy:
        env:
        - name: MAVEN_MIRROR_URL
          value: ${MAVEN_MIRROR_URL}
        - name: ARTIFACT_DIR
          value: ${ARTIFACT_DIR}
        forcePull: true
        from:
          kind: ImageStreamTag
          name: jboss-webserver31-tomcat8-openshift:1.2
          namespace: ${IMAGE_STREAM_NAMESPACE}
      type: Source
    triggers:
    - github:
        secret: ${GITHUB_WEBHOOK_SECRET}
      type: GitHub
    - generic:
        secret: ${GENERIC_WEBHOOK_SECRET}
      type: Generic
    - imageChange: {}
      type: ImageChange
    - type: ConfigChange
- apiVersion: v1
  kind: DeploymentConfig
  metadata:
    labels:
      application: ${APPLICATION_NAME}
    name: ${APPLICATION_NAME}
  spec:
    replicas: 1
    selector:
      deploymentConfig: ${APPLICATION_NAME}
    strategy:
      type: Recreate
    template:
      metadata:
        labels:
          application: ${APPLICATION_NAME}
          deploymentConfig: ${APPLICATION_NAME}
        name: ${APPLICATION_NAME}
      spec:
        containers:
        - env:
          - name: JWS_HTTPS_CERTIFICATE_DIR
            value: /etc/jws-secret-volume
          - name: JWS_HTTPS_CERTIFICATE
            value: ${JWS_HTTPS_CERTIFICATE}
          - name: JWS_HTTPS_CERTIFICATE_KEY
            value: ${JWS_HTTPS_CERTIFICATE_KEY}
          - name: JWS_HTTPS_CERTIFICATE_PASSWORD
            value: ${JWS_HTTPS_CERTIFICATE_PASSWORD}
          - name: JWS_ADMIN_USERNAME
            value: ${JWS_ADMIN_USERNAME}
          - name: JWS_ADMIN_PASSWORD
            value: ${JWS_ADMIN_PASSWORD}
          image: ${APPLICATION_NAME}
          imagePullPolicy: Always
          name: ${APPLICATION_NAME}
          ports:
          - containerPort: 8778
            name: jolokia
            protocol: TCP
          - containerPort: 8080
            name: http
            protocol: TCP
          - containerPort: 8443
            name: https
            protocol: TCP
          readinessProbe:
            exec:
              command:
              - /bin/bash
              - -c
              - curl --noproxy '*' -s -u ${JWS_ADMIN_USERNAME}:${JWS_ADMIN_PASSWORD}
                'http://localhost:8080/manager/jmxproxy/?get=Catalina%3Atype%3DServer&att=stateName'
                |grep -iq 'stateName *= *STARTED'
          volumeMounts:
          - mountPath: /etc/jws-secret-volume
            name: jws-certificate-volume
            readOnly: true
        terminationGracePeriodSeconds: 60
        volumes:
        - name: jws-certificate-volume
          secret:
            secretName: ${JWS_HTTPS_SECRET}
    triggers:
    - imageChangeParams:
        automatic: true
        containerNames:
        - ${APPLICATION_NAME}
        from:
          kind: ImageStreamTag
          name: ${APPLICATION_NAME}:latest
      type: ImageChange
    - type: ConfigChange
parameters:
- description: The name for the application.
  displayName: Application Name
  name: APPLICATION_NAME
  required: true
  value: jws-app
- description: 'Custom hostname for http service route.  Leave blank for default hostname,
    e.g.: <application-name>-<project>.<default-domain-suffix>'
  displayName: Custom http Route Hostname
  name: HOSTNAME_HTTP
- description: 'Custom hostname for https service route.  Leave blank for default
    hostname, e.g.: secure-<application-name>-<project>.<default-domain-suffix>'
  displayName: Custom https Route Hostname
  name: HOSTNAME_HTTPS
- description: Git source URI for application
  displayName: Git Repository URL
  name: SOURCE_REPOSITORY_URL
  required: true
  value: https://github.com/jboss-openshift/openshift-quickstarts.git
- description: Git branch/tag reference
  displayName: Git Reference
  name: SOURCE_REPOSITORY_REF
  value: "1.2"
- description: Path within Git project to build; empty for root project directory.
  displayName: Context Directory
  name: CONTEXT_DIR
  value: tomcat-websocket-chat
- description: The name of the secret containing the certificate files
  displayName: Secret Name
  name: JWS_HTTPS_SECRET
  required: true
  value: jws-app-secret
- description: The name of the certificate file within the secret
  displayName: Certificate Name
  name: JWS_HTTPS_CERTIFICATE
  value: server.crt
- description: The name of the certificate key file within the secret
  displayName: Certificate Key Name
  name: JWS_HTTPS_CERTIFICATE_KEY
  value: server.key
- description: The certificate password
  displayName: Certificate Password
  name: JWS_HTTPS_CERTIFICATE_PASSWORD
- description: JWS Admin User
  displayName: JWS Admin Username
  from: '[a-zA-Z0-9]{8}'
  generate: expression
  name: JWS_ADMIN_USERNAME
  required: true
- description: JWS Admin Password
  displayName: JWS Admin Password
  from: '[a-zA-Z0-9]{8}'
  generate: expression
  name: JWS_ADMIN_PASSWORD
  required: true
- description: GitHub trigger secret
  displayName: Github Webhook Secret
  from: '[a-zA-Z0-9]{8}'
  generate: expression
  name: GITHUB_WEBHOOK_SECRET
  required: true
- description: Generic build trigger secret
  displayName: Generic Webhook Secret
  from: '[a-zA-Z0-9]{8}'
  generate: expression
  name: GENERIC_WEBHOOK_SECRET
  required: true
- description: Namespace in which the ImageStreams for Red Hat Middleware images are
    installed. These ImageStreams are normally installed in the openshift namespace.
    You should only need to modify this if you've installed the ImageStreams in a
    different namespace/project.
  displayName: ImageStream Namespace
  name: IMAGE_STREAM_NAMESPACE
  required: true
  value: openshift
- description: Maven mirror to use for S2I builds
  displayName: Maven mirror URL
  name: MAVEN_MIRROR_URL
- description: List of directories from which archives will be copied into the deployment
    folder. If unspecified, all archives in /target will be copied.
  name: ARTIFACT_DIR
```

  Let's take a closer look at this file.
  Object *kind* is template as denoted here: ``` kind: Template ``` and it has a child element called ```objects``` which is a list. In this list, there can be as many objects as you like; it's pretty common to put objects that belong to the same application in the same template.

Another important element of the template is called ```parameters```. 
See the following excerpt:
```
...
parameters:
- description: The name for the application.
  displayName: Application Name
  name: APPLICATION_NAME
  required: true
  value: jws-app
...
```

Each *parameter* defined like this, can then be used in the *objects* section for easy text replacement.
See the following excerpt where application label's value is replaced with *APPLICATION_NAME* parameters's value:
```
    labels:
      application: ${APPLICATION_NAME}
```

### Processing templates

For creating the objects that are defined in the template, the most common mistake is to run the following command:``` oc create -f template_app.yaml```

Running this command **creates a template object** instead of creating the **objects defined in the template** i.e. if the template defined in the file *template_app.yaml* is named *my-app*, then ```oc get template my-app``` would return the my-app object back.

In order to create the objects that are defined in a template(and not create a template object for reuse), then template needs to be processed first. This is done with ```oc process``` command.

Run ```oc process --help``` to see some very helpful examples. ```oc process``` just prints the result of processing to STDOUT so the only thing left to do is piping it to *oc create* e.g.: ```  oc process -f template.json | oc create -f - ```. For processing a template that already exists on openshift ``` oc process foo PARM1=VALUE1 PARM2=VALUE2 ```

