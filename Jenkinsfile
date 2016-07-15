node {
    stage 'Git checkout'
    echo 'Checking out git repository'
    git url: 'https://github.com/rafaeltuelho/jboss-kitchensink'

    stage 'Build project with Maven'
    echo 'Building project'
    def mvnHome = tool 'M3'
    def javaHome = tool 'jdk8'
    sh "${mvnHome}/bin/mvn clean package -Popenshift -DskipTests"

    stage 'Build image and deploy in Dev'
    echo 'Building docker image and deploying to Dev'
    buildKitchensink('kitchensink-dev')

    stage 'Automated tests'
    echo 'This stage simulates automated tests'
    echo 'Create a test project to be user by JBoss Arquilian integration tests'

    waitUntil{
      buildArquilianContainer('kitchensink-test')
    }
    echo 'sleeping 5s'
    sleep 5
    // -Dmaven.test.failure.ignore verify"
    sh "${mvnHome}/bin/mvn -B clean test -Parq-wildfly-remote"
    echo 'clean arquilian test resources'
    //cleanArquilianResources('kitchensink-test')

    stage 'Deploy to QA'
    echo 'Deploying to QA'
    deployKitchensink('kitchensink-dev', 'kitchensink-qa')

    stage 'Wait for approval'
    input 'Aprove to production?'

    stage 'Deploy to production'
    echo 'Deploying to production'
    deployKitchensink('kitchensink-dev', 'kitchensink')
}

// Creates a Build and triggers it
def buildArquilianContainer(String project){
    projectSet(project)

    sh "oc new-build --name=kitchensink-arq --binary --strategy=docker -l app=kitchensink-arq || echo 'Build exists'"
    sh "oc start-build kitchensink-arq --from-dir=./osev3/docker/custom-wildfly10 --wait --follow"
    sh "oc new-app kitchensink-arq -l app=kitchensink-arq || echo 'Container already Exists'"
}

def cleanArquilianResources(String project){
    projectSet(project)
    sh "oc delete pods,services,buildconfigs,builds,deploymentconfigs,replicationcontrollers -l app=kitchensink-arq"
}

// Creates a Build and triggers it
def buildKitchensink(String project){
    projectSet(project)

    sh "oc new-build --name=kitchensink --binary --strategy=docker -l app=kitchensink || echo 'Build exists'"
    sh "oc start-build kitchensink --from-dir=./osev3/docker/custom-eap7 --follow"
    appDeploy()
}

// Tag the ImageStream from an original project to force a deployment
def deployKitchensink(String origProject, String project){
    projectSet(project)
    sh "oc policy add-role-to-user system:image-puller system:serviceaccount:${project}:default -n ${origProject}"
    sh "oc tag ${origProject}/kitchensink:latest ${project}/kitchensink:latest"
    appDeploy()
}

// Login and set the project
def projectSet(String project){
    //Use a credential called openshift-dev
    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'openshift-dev', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
        sh "oc login --insecure-skip-tls-verify=true -u $env.USERNAME -p $env.PASSWORD https://10.1.2.2:8443"
    }
    sh "oc new-project ${project} || echo 'Project exists'"
    sh "oc project ${project}"
}

// Deploy the project based on a existing ImageStream
def appDeploy(){
    sh "oc new-app kitchensink -l app=kitchensink || echo 'Aplication already Exists'"
    sh "oc expose service kitchensink || echo 'Service already exposed'"
    sh 'oc patch dc/kitchensink -p \'{"spec":{"template":{"spec":{"containers":[{"name":"kitchensink","readinessProbe":{"httpGet":{"path":"/","port":8080}}}]}}}}\''
}
