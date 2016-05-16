# Lab 7: Troubleshooting, was ist im Pod?

In diesem Lab wird aufgezeigt, wie man im Fehlerfall und Troubleshooting vorgehen kann und welche Tools einem dabei zur Verfügung stehen.

## In Container einloggen

Container werden als unveränderbare Infrastruktur behandelt und sollen generell nicht bspw. durch einloggen über SSH modifiziert werden. Dennoch gibt es UseCases bei den man sich in die Container für Debugging und Analysen einloggen muss.

## Aufgabe: LAB7.1

Mit OpenShift können Remote Shells in die Pods geöffnet werden ohne, dass man in jeden Pod einen SSH Deamon installieren muss. Dafür steht einem der Befehl `oc rsh` zur Verfügung.

Wählen Sie mittels `oc get pods` einen Pod aus und führen Sie den folgenden Befehl aus:
```
$ oc rsh [POD] 
```

Sie können nun über diese Shell Analysen im Container ausführen:

```
bash-4.2$ ls -la
total 16                                                                        
drwxr-xr-x. 7 default root   99 May 16 13:35 .                                  
drwxr-xr-x. 4 default root   54 May 16 13:36 ..                                 
drwxr-xr-x. 6 default root   57 May 16 13:35 .gradle                            
drwxr-xr-x. 3 default root   18 May 16 12:26 .pki                               
drwxr-xr-x. 9 default root 4096 May 16 13:35 build                              
-rw-r--r--. 1 root    root 1145 May 16 13:33 build.gradle                       
drwxr-xr-x. 3 root    root   20 May 16 13:34 gradle                             
-rwxr-xr-x. 1 root    root 4971 May 16 13:33 gradlew                            
drwxr-xr-x. 4 root    root   28 May 16 13:34 src 
```

## Aufgabe: LAB7.2

Einzelne Befehle innerhalb des Container können über `oc exec` ausgeführt werden

```
$ oc exec [POD] env
```


```
$ oc exec example-spring-boot-4-8mbwe env
PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=example-spring-boot-4-8mbwe
KUBERNETES_SERVICE_PORT_DNS_TCP=53
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=172.30.0.1
KUBERNETES_PORT_53_UDP_PROTO=udp
KUBERNETES_PORT_53_TCP=tcp://172.30.0.1:53
...
```

## Logfiles anschauen

Die Logfiles zu einem Pod können sowohl in der Web Console wie auch im CLI angezeigt werden.

```
$ oc logs [POD]
```
Der Parameter `-f` bewirkt analoges Verhalten wie `tail -f`

Befindet sich ein Pod Im Status **CrashLoopBackOff**, er konnte also nicht gestartet werden, auch nach n Versuchen. Können die Logfiles mittels

 ```
$ oc logs -p [POD]
```
angezeigt werden.


### Logging EFK Stack 

Mit OpenShift wird ein EFK mitgeliefert, der sämtliche Logfiles sammelt, rotiert und aggregiert. 

TODO

**Bestpractice Logging auf STDOUT**

Innerhalb eines Container sollen die Logs jeweils auf STDOUT geschrieben werden, damit die Plattform sich entsprechend um die Aggregierung der Logs kümmern kann.



---

**Ende Lab 7**

[<< zurück zur Übersicht] (../README.md)
