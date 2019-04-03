# Lab: Logging EFK Stack

Mit OpenShift wird ein EFK (Elasticsearch, Fluentd, Kibana) Stack mitgeliefert, der sämtliche Logfiles sammelt, rotiert und aggregiert. Kibana erlaubt es Logs zu durchsuchen, zu filtern und grafisch aufzubereiten.

> [Weitere Informationen](https://docs.openshift.com/container-platform/3.11/install_config/aggregate_logging.html)

**Best Practice JSON Logging auf STDOUT**

Innerhalb eines Container sollten die Logs jeweils auf STDOUT geschrieben werden, damit sich die Plattform entsprechend um die Aggregierung der Logs kümmern kann. Falls die Logs im JSON Format geschrieben werden zerlegt der EFK Stack die Logs automatisch und erlaubt ein Filtern auf Knopfdruck.

Java EE Beispielanwendung mit Log4j 2 JSON Logging installieren:

```
$ oc new-app openshift/wildfly-100-centos7~https://github.com/appuio/ose3-java-logging.git
$ oc expose svc ose3-java-logging
```

Danach mit dem Browser die Applikation mehrmals aufrufen um einige Logeinträge zu generieren und anschliessend in der Webconsole unter Browse > Pods das neu erstellte Pod und anschliessend das Log Tab auswählen. Hier ist nun direkt der Standardoutput eines Pods der Applikation sichtbar.

Über den "View Archive" Knopf kann direkt zu den aggregierten Logs der Applikation im EFK Stack gewechselt werden. Hier sind nun die Logs aller Pods der ausgewählten Applikation zeitlich sortiert, und sofern im JSON format, nach den einzelnen Feldern geparsed zu sehen:

![Kibana Screenshot](/images/kibana1.png)

Alle von der Applikation geloggten Felder sind jetzt noch mit einer Warnanzeige versehen, da sie noch nicht indiziert sind und somit nicht danach gefiltert, sortiert, etc. werden kann. Um dies zu beheben muss unter Settings > .all auf den reload Button ![Kibana Reload Button](/images/kibana2.png) gedrückt werden. Danach kann z.B. durch Drücken auf ein Feld eines Logeintrages nach allen Einträgen mit dem selben Wert gesucht werden.

Die Strukturierung der Log4j 2 JSON Ausgabe ist derzeit für die von der Applikation beigesteuerten Felder nicht ideal:

    "contextMap_0_key": "url",
    "contextMap_0_value": "http://ose3-java-logging-dtschan.ose3-lab.puzzle.ch/",
    "contextMap_1_key": "remoteAddr",
    "contextMap_1_value": "10.255.1.1",
    "contextMap_2_key": "freeMem",
    "contextMap_2_value": "16598776",

Gewünscht wäre:

    "url": "http://ose3-java-logging-dtschan.ose3-lab.puzzle.ch/",
    "remoteAddr": "10.255.1.1",
    "freeMem": "16598776",

Was auch innerhalb von Kibana zu einer verständlicheren Darstellung führen würde. Siehe auch: https://issues.apache.org/jira/browse/LOG4J2-623.

---

**Ende**

[← zurück zur Übersicht](../README.md)
