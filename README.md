# Jenkins DE
Mit diesem Projekt wird eine eigene Möglichkeit zur Entwicklung des Jenkins geschaffen. \
Als Basis gilt vorerst das s2i Image des Jenkins 2 auf Centos7. \
Wenn es ein anderes oder zusätzliche BasisImages geben sollte, dann werden diese hier aufgelistet.
- openshift/jenkins-2-centos7  
## Voraussetzungen
Mit diesem Vorgehen setzen wir ein Secret mit vorgegebenen Namen voraus `github-de-technical-secret`.\
Wenn dies noch nicht vorhanden ist, dann bitte folgendes tun.\
Im ausgecheckten Projekt folgende Datei anpassen: `oc_template/secrets/deploy_secrets.sh`
Bitte der Variablen `USER_TOKEN=` einen github Token einfügen und darauf achten, dass der Token wieder aus der Datei 
entfernt und nicht persistiert wird.
Dann das Secret im openShift Projekt erstellen.
```
$ cd oc_template/secrets/
$ sh deploy_secrets.sh
``` 
Dies ist keine dauerhafte Lösung und wird ganz sicher noch umgestellt!!!!
## Entwicklung
Es werden alle Files, die dem Image hinzugefügt oder am Image angepasst werden sollen im Verzeichnis `/containerfiles` 
abgelegt. \
Dateien aus dem Basis Image, welche angepasst werden, wurden 1:1 kopiert und in der Struktur abgelegt. Zusätzliche 
Inhalte sind mit Kommentaren gekenntzeichnet. \
Beispiel:
```
############################################
#  Anpassungen / axa-de / START
############################################
...
############################################
#  Anpassungen / axa-de / ENDE
############################################
```
### Anpassung Maven
Maven wird im Image direkt zur Verfügung gestellt, um im ersten Schritt mit hoher Geschwindigkeit die Buildschritte mit 
Maven starten zu können. Das Starten der Slaves ist derzeit nicht performant. \
Sobald eine performante Lösung mit den Slaves bekannt ist, sollen auf dem Master keine spezifischen Installationen 
bereitgestellt werden.

Konfiguration von Maven im Jenkins kann mit `tmp/axa-resources/jenkins/hudson.task.Maven.xml` erfolgen.

Die Installation von Maven erfolgt mit `tmp/axa-resources/jenkins/setup-axa-jenkins.sh`, welches im Dockerfile gestartet 
wird. 
### Anbindung an Nexus DE
Damit Maven mit dem Nexus DE kommunizieren kann ist eine Konfiguration in der settings.xml in Maven notwendig.
Konfiguriert sind die Repositories, die erreicht werden sollen. Die Konfiguration zum Proxy sollte dynamisch mit dem Start
des Jenkins erfolgen und in die settings.xml geschrieben werden. Infos zu Host und Port des Proxy soll über Umgebungsvariablen 
erfolgen. \
Alternativ kann dies als Parameter beim Aufruf von Maven mitgegeben werden. Nachteil ist, dass dies im JENKINSFILE 
anzugeben wäre.

Wichtig ist, dass Jenkins ein Zertifikat für den Aufruf des Nexus DE benötigt. Momentan wurde dies im Image unter 
`containerfiles\etc\pki\ca-trust\extracted` abgelegt. Hier muss noch geschaut werden wie das Zertifikat vom Jenkins beim 
Start aus dem openShift Projekt ziehen kann. 
### Anpassung Jenkins Slaves
Slaves werden im Jenkins über die kubernetes Slaves konfiguriert. Hierzu ist das Originalfile im Projekt aufzunehmen und 
anzupassen. `usr/local/bin/kube-slave-common.sh`  
## Builder
Für den Build des Jenkins wird ein Builder geliefert, der gleichzeitig 2 ImageStreamTags mitbringt.
* Der ImageStreamTag des BasisImages ist als Proxy für das eigentliche BasisImages zu sehen.
* Der ImageStreamTag des zu bauenden Jenkins soll später füe alle nutzbar sein, die den Jenkins im eigenen openShift 
Projekt installieren. 
Der Builder baut ein Docker Image und legt es im ImageStreamTag ab 
## Pipeline
Für den Bau des Jenkins soll ein eigenes JENKINSFILE entwickelt werden, welches den Build und die Tests steuert und 
Ergebnisse in den MetricStore wirft. \
Als Basis gelten die Pipelines, die über das Projekt `https://github.axa.com/BuildPipelineGilde/buildePipeline` 
bereitgestellt werden. \
* Beim Build soll der Builder angestoßen werden.
* Bei Laufzeittests soll das Deployment genutzt werden. 
## Deployment
Für den zu bauenden Jenkins wird ein eigenes Deployment geliefert, welche später bei dynamischen Test zum
Container oder dem Jenkins aus einer Pipeline heraus genutzt werden soll. \
Dieses Deployment ist derzeit die Basis bzw. die Entwicklung des Deployments für den Jenkins, welches über
`https://github.axa.com/BuildPipelineGilde/buildePipeline` anderen Teams in ihren openShift Projekten genutzt werden 
soll. Hier können wir noch mal überlegen ob es Sinn macht, oder ob man dies auch anders angehen kann. 