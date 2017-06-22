podTemplate(
    inheritFrom: "maven",
    label: "myJenkinsMavenSlave",
    cloud: "openshift",
    volumes: [
        persistentVolumeClaim(claimName: "m2repo", mountPath: "/tmp/.m2")
    ]) {
      node('myJenkinsMavenSlave') {
        stage('Git checkout') {
          echo 'Checking out git repository'
          git branch: 'ocp3.5', url: 'http://gogs-cicd-tools.apps.ocp.acme.com/gogsadmin/jboss-kitchensink.git'
        }

        stage('Build project with Maven') {
          echo 'Building project'
          sh "mvn clean package -Popenshift -DskipTests"
        }

        stage('Build image and deploy in Dev') {
          echo 'Building docker image and deploying to Dev'
          buildKitchensink('kitchensink-dev')
        }

        stage('Automated tests') {
          echo 'This stage simulates automated tests'
          echo 'Create a test project to be user by JBoss Arquilian integration tests'

          waitUntil{
            buildArquilianContainer('kitchensink-test')
          }
          echo 'sleeping 15s...'
          sleep 15
          // -Dmaven.test.failure.ignore verify"
          retry(2) {
             sh "mvn -B clean test -Parq-wildfly-remote"
          }
          //echo 'clean arquilian test resources'
          //cleanArquilianResources('kitchensink-test')
        }

        stage('Deploy to QA') {
          echo 'Deploying to QA'
          deployKitchensink('kitchensink-dev', 'kitchensink-qa')
        }

        stage('Wait for approval') {
          input 'Aprove to production?'
        }

        stage('Deploy to production') {
          echo 'Deploying to production'
          deployKitchensink('kitchensink-dev', 'kitchensink')
        }// stage
      } //node
} // podTemplate

// Creates a Build and triggers it
def buildArquilianContainer(String namespace){
    projectSet(namespace)

    sh "oc new-build --name=kitchensink-arq --binary --strategy=docker -l app=kitchensink-arq -n ${namespace} || echo 'Build exists'"
    sh "oc start-build kitchensink-arq -n ${namespace} --from-dir=./osev3/docker/custom-wildfly10 --wait --follow"
    echo "This is the build number: ${env.BUILD_NUMBER}"
    sh "oc new-app kitchensink-arq -l app=kitchensink-arq -n ${namespace} || echo 'Container already Exists'"

    return true
}

def cleanArquilianResources(String namespace){
    projectSet(namespace)
    sh "oc delete pods,services,buildconfigs,builds,deploymentconfigs,replicationcontrollers,is,imagestreamtags,images -l app=kitchensink-arq -n ${namespace}"
}

// Creates a Build and triggers it
def buildKitchensink(String namespace){
    projectSet(namespace)

    sh "oc new-build --name=kitchensink --binary --strategy=docker -l app=kitchensink -n ${namespace} || echo 'Build exists'"
    sh "oc start-build kitchensink -n ${namespace} --from-dir=./osev3/docker/custom-eap7 --follow"
    echo "This is the build number: ${env.BUILD_NUMBER}"
    appDeploy(namespace)
}

// Tag the ImageStream from an original namespace to force a deployment
def deployKitchensink(String origNamespace, String namespace){
    projectSet(namespace)
    sh "oc policy add-role-to-user system:image-puller system:serviceaccount:${namespace}:default -n ${origNamespace}"
    sh "oc tag ${origNamespace}/kitchensink:latest ${namespace}/kitchensink:latest -n ${namespace}"
    appDeploy(namespace)
}

// Try to create a namespace namespace
def projectSet(String namespace){
    sh "oc new-project ${namespace} || echo 'namespace exists'"
    sh "oc project ${namespace}"
}

// Deploy the project based on a existing ImageStream
def appDeploy(String namespace){
    sh "oc new-app kitchensink -l app=kitchensink -n ${namespace} || echo 'Aplication already Exists'"
    sh "oc expose service kitchensink -n ${namespace} || echo 'Service already exposed'"
    sh "oc patch dc/kitchensink -n ${namespace} -p '{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"kitchensink\",\"readinessProbe\":{\"httpGet\":{\"path\":\"/\",\"port\":8080}}}]}}}}'"
}
