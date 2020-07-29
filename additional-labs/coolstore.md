# Coolstore

Deploy your own version of coolstore

```
oc new-project coolstore-userXY
oc process -f https://raw.githubusercontent.com/jbossdemocentral/coolstore-microservice/stable-ocp-3.11/openshift/coolstore-template.yaml | oc create -f -
oc status
```

Wait till all images are built and all pods are deployed.

Familiarize yourself with deployed environment. List services and visit the cool store app.

Not all services are running and thus not all features of the store are available, what happens if you start more of the services? Which features do appear how?

You can test the individual apps from within the cluster:

```
oc rsh $(oc get pods -o name -l app=coolstore-gw)
curl http://catalog:8080/api/products
curl http://inventory:8080/api/availability/329299
curl http://cart:8080/api/cart/FOO
curl http://rating:8080/api/rating/329299
curl http://review:8080/api/review/329299
```

# Accessing jolokia

Read more about jolokia [here](https://developers.redhat.com/blog/2016/03/30/jolokia-jvm-monitoring-in-openshift/)

Each of the deployed Java applications has JMX over the jolokia Port (8778) enabled. You can attach to each of them through the pod view on the WebUI.

What kind of interesting information can you find?
