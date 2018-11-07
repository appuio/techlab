# Lab 5: Creating Routes

In this lab we will make the application from [Lab 4](04_deploy_dockerimage.md) accessible **http** from the Internet.

## Routes

The `oc new-app` command from the previous [Lab](04_deploy_dockerimage.md)  does not create a route. Thus our service is not accessible from the  *outside*. If a service is to be made available, a route must be set up. The OpenShift router recognizes on the basis of the host header to which service a request must be directed.

The following protocols are currently supported:

- HTTP
- HTTPS ([SNI](https://en.wikipedia.org/wiki/Server_Name_Indication))
- WebSockets
- TLS mit [SNI](https://en.wikipedia.org/wiki/Server_Name_Indication)

## Task: LAB5.1

Make sure you are in the project `[USER]-dockerimage`. **Hint:** `oc project [USER]-dockerimage`

Create a route for the  `example-spring-boot`  service and make it publicly available.

**Hint:** Using `oc get routes` you can display the routes of a project.

```bash
$ oc get routes

```

Currently there is no route. Now we need the service name:

```
$ oc get services
NAME                  CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
example-spring-boot   172.30.124.20   <none>        8080/TCP   11m
```

And now we want to publish / expose this service:

```
$ oc expose service example-spring-boot
```

By default, an http route is created.

We can use `oc get routes` to check whether the route has been created.

```bash
$ oc get routes
NAME                  HOST/PORT                                   PATH      SERVICE                        TERMINATION   LABELS
example-spring-boot   example-spring-boot-techlab.app.appuio.ch             example-spring-boot:8080-tcp                 app=example-spring-boot
```

The application can now be accessed from the Internet using the specified hostname, so you can now access the application.

**Hint:** If no hostname is given, the default name is used: *servicename-project.osecluster*

This route with the hostname is now also visible in the web console's overview.

---

**End of lab 5**

<p width="100px" align="right"><a href="06_scale.md">Scaling →</a></p>

[← back to overview](../README.md)
