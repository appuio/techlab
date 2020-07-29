# App monitoring with prometheus

## Switch to the prometheus project

You have a project pre-provisioned where you will run your workload to monitor, to which you are now switching:

```bash
oc project prometheus-[USER]
```

## Deploy example app

We will deploy our familiar ruby-ex application on a dedication branch called `prom` into that project by using the already known new-app command:

```bash
oc new-app openshift/ruby:2.5~https://git.apps.cluster-centris-0c77.centris-0c77.example.opentlc.com/training/ruby-ex.git#prom --name prometheus-app -l app=prometheus-app
```

Expose the service as route

```bash
oc create route edge --insecure-policy=Redirect --service=prometheus-app
```

Verify that you are able to access the application:

```bash
curl https://$(oc get route prometheus-app -o jsonpath='{.status.ingress[*].host}') -o /dev/null
```

The application automatically exposes metrics under `/metrics` that can be scraped by the application prometheus.

You can check the available resources by accessing the `/metrics` endpoint:

```bash
$ curl -s https://$(oc get route prometheus-app -o jsonpath='{.status.ingress[*].host}')/metrics
# TYPE http_server_requests_total counter
# HELP http_server_requests_total The total number of HTTP requests handled by the Rack application.
http_server_requests_total{code="200",method="get",path="/metrics"} 7.0
http_server_requests_total{code="200",method="get",path="/"} 1.0
[...]
```

## Setting up metrics collection

To use the metrics exposed by your service, you need to configure OpenShift Monitoring to scrape metrics from the `/metrics` endpoint. You can do this using a ServiceMonitor, a custom resource definition (CRD) that specifies how a service should be monitored, or a PodMonitor, a CRD that specifies how a pod should be monitored. The former requires a Service object, while the latter does not, allowing Prometheus to directly scrape metrics from the metrics endpoint exposed by a Pod.

We are now going to first monitor the service by applying the following resource:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: prometheus-app
  name: prometheus-app-monitor
spec:
  endpoints:
  - interval: 30s
    port: 8080-tcp
    scheme: http
  selector:
    matchLabels:
      app: prometheus-app
```

Important here is the selector using labels and the endpoint that scrapes metrics every 30s from `/metrics` on the particular port from the service.

Either copy the resource definition into the Import YAML in the webui

1. Developer view
1. select project prometheus-[USER]
1. click on `+Add`
1. select the YAML box
1. paste the above YAML
1. click on Create

or into a file and apply it:

```bash
oc apply -f prometheus-app-service-monitor.yaml
```

You can check that the ServiceMonitor is running:

```bash
$ oc get servicemonitor
NAME                     AGE
prometheus-app-monitor   19s
```

## Accessing the metrics of your service

Once you have enabled monitoring your own services, deployed a service, and set up metrics collection for it, you can access the metrics of the service through the WebUI.

To access the metrics as a developer, go to the OpenShift Container Platform web console, switch to the Developer Perspective, then click Advanced → Metrics. Select the project you want to see the metrics for.

There you can add prometheus queries based on the metrics, that will be shown in the integrated prometheus UI. You can read about them Metrics UI [here](https://docs.openshift.com/container-platform/4.3/monitoring/cluster_monitoring/examining-cluster-metrics.html#examining-cluster-metrics).

As an example select the metric for `http_server_requests_total`, this shows you all metrics with that type. You can also restrict to only get metrics from the prometheus-app: `http_server_requests_total{service="prometheus-app"}`

Click on Run Queries and see the Graph and Console.

Visit the app and see how your access is counted within prometheus.

Now let's generate some load. The following command, will generate every once in a while a call to /not-found, while otherwise calling /, so we should get some 404 metrics:

```bash
while true; do url="https://$(oc get route prometheus-app -o jsonpath='{.status.ingress[*].host}')/$(if [ $(( ( RANDOM % 10 )  + 1 )) -eq 10 ]; then echo "not-found"; fi)"; echo $url; curl -k -o /dev/null -s $url; sleep 0.25; done
```
**Note:** You can later stop the curl by executing `CTRL-C`.

It will take 30s to query the new metrics, but they will be shown afterwards and we will see metrics for the path `/not-found`.

We can now see how many http-codes we get on average over the last 5 minutes:

```
sum(rate(http_server_requests_total{service="prometheus-app"}[5m])) by (code)
```

This can also be grouped additionally by path:

```
sum(rate(http_server_requests_total{service="prometheus-app"}[5m])) by (code,path)
```


## Scale up

Scale the prometheus-app up to multiple pods.

Do you find the new pods inside Prometheus? Can you graph by return code and pod, so you can figure out which pods has the main issues?

## Bonus

Remember the spring boot app? It also has metrics available. Can you deploy this app again in our prometheus project and scrape this endpoint as well?
