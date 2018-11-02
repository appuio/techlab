# Lab: Logging EFK Stack

Witch OpenShift an EFK (Elasticsearch, Fluentd, Kibana) Stack will be provided. It collects all the log files, rotates and aggregates them. Kibana allows it to search through the logs and to filter as well as to represent them graphically.

> [More Information](https://docs.openshift.com/container-platform/3.5/install_config/aggregate_logging.html)

**Best Practice JSON Logging to STDOUT**

In a container logs should be written to STDOUT so that the platform can take care of their aggregation. If the logs are written in the JSON format, EFK stack will automatically dis-aggregate them and allows filtering by the push of a button.

Install a Java EE example with Log4j 2 JSON Logging:

```bash
oc new-app openshift/wildfly-100-centos7~https://github.com/appuio/ose3-java-logging.git
oc expose svc ose3-java-logging
```

Afterwards open the application several times with your browser to generate a few logs, then open the web console under Browse > Pods find the new pod and klick its Log tab. Now you can see its STDOUT.

Via the "View Archive" button you can jump directly to the aggregated logs of the application in the EFK stack. Here there are all the logs of all the pods of the chosen application sorted after time, and if they are in a JSON format, parsed after the different fields:

![Kibana Screenshot](/images/kibana1.png)

All logged fields of an application are still shown with a warning sign since they aren't indexed now and so can't be filtert or sorted yet. To resolve this klick under Settings > .all the reload button ![Kibana Reload Button](/images/kibana2.png). Afterwards it is possible to klick a field of a log entry to get all the entries with the same value.

The structure of the Log4j 2 JSON output isn't ideal at the moment:

    "contextMap_0_key": "url",
    "contextMap_0_value": "http://ose3-java-logging-dtschan.ose3-lab.puzzle.ch/",
    "contextMap_1_key": "remoteAddr",
    "contextMap_1_value": "10.255.1.1",
    "contextMap_2_key": "freeMem",
    "contextMap_2_value": "16598776",

desired would be:

    "url": "http://ose3-java-logging-dtschan.ose3-lab.puzzle.ch/",
    "remoteAddr": "10.255.1.1",
    "freeMem": "16598776",

Which would also lead to a more comprehensible representation in Kibana. See: https://issues.apache.org/jira/browse/LOG4J2-623.

---

**End**

[← back to overview](../README.md)
