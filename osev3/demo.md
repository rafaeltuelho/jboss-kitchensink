# Openshift Enterprise 3.2 (CDK)

## References
 * CDK 2: https://access.redhat.com/documentation/en/red-hat-container-development-kit?version=2.1/

 * Create an OpenShift 3 Application in Red Hat JBoss Developer Studio: https://access.redhat.com/articles/2380251

 * Red Hat Hello World MSA demo: https://github.com/redhat-helloworld-msa/helloworld-msa
  * CI/CD Pipeline: https://github.com/redhat-helloworld-msa/helloworld-msa/blob/master/cicd.adoc

## Setup

 * Start CDK Vagrant box

```
cd $DEMO_HOME
cd $CDK_HOME/components/rhel/rhel-ose

vagrant up
vagrant provision

vagrant service-manager status
Configured services:
docker - running
openshift - running
kubernetes - stopped
```
 * Install Openshift xPaaS official EAP images

on your locahost
```
cd /tmp
git clone https://github.com/jboss-openshift/application-templates.git
cd application-templates/

oc login https://10.1.2.2:8443
Authentication required for https://10.1.2.2:8443 (openshift)
Username: admin
Password:
Login successful.

# load the JBoss Image Streams
oc create -n openshift -f jboss-image-streams.json

# load some templates
oc create -n openshift -f eap -f sso
```

 * Install a custom Jenkins Build

on your localhost
```
oc login https://10.1.2.2:8443
Authentication required for https://10.1.2.2:8443 (openshift)
Username: admin
Password:
Login successful.

oc create -f https://raw.githubusercontent.com/redhat-helloworld-msa/jenkins/master/custom-jenkins.build.yaml

oc start-build custom-jenkins-build --follow

```

 * Create a CI project on OSE

```
oc login https://10.1.2.2:8443
Authentication required for https://10.1.2.2:8443 (openshift)
Username: openshift-dev
Password:
Login successful.

oc new-project ci --display-name="Continuous Integration for OpenShift" --description="This project holds all continuous integration required infrastructure, like Nexus, Jenkins,..."

oc new-app -p MEMORY_LIMIT=1024Mi https://raw.githubusercontent.com/openshift/origin/master/examples/jenkins/jenkins-ephemeral-template.json

```

 * Install a Custom Sonatype Nexus Maven repo manager

  * create the Nexus app using the `nexus-persistent` template

  ```
  oc create -f https://raw.githubusercontent.com/jorgemoralespou/nexus-ose/master/nexus/ose3/nexus-resources.json -n ci
  oc volumes dc/nexus --add --claim-size=3Gi --mount-path=/sonatype-work --claim-name=nexus-claim --name=pvol03
  oc new-app --template=nexus-persistent --param=APPLICATION_HOSTNAME=nexus-ci.cdk.vm.10.2.2.2.xip.io,SIZE=5Gi
  ```

## URLs

 * Openshift Web Console
  * https://10.1.2.2:8443/console
  * credenciais:
    * admin/admin
    * openshift-dev/devel

 * Jenkins
  * https://jenkins-ci.cdk.vm.10.1.2.2.xip.io/
  * credenciais:
    * admin/password

 * Nexus
  * External DNS: http://nexus-ci.cdk.vm.10.1.2.2.xip.io/
  * Internal DNS: nexus.ci.svc.cluster.local
  * credenciais:
    * admin/admin123

## Use Cases

```
git commit -am "fixing arquilian tests"
git push -u origin master

oc login
oc rsh jenkins-1-<container id>
export TERM=xterm
tail -F /var/lib/jenkins/jobs/JBoss\ Kitchensink\ Quickstart/workspace/target/wildfly-10.0.0.Final/standalone/log/server.log
```
