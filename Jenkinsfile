node {
    stage 'Git checkout'
    echo 'Checking out git repository'
    git url: 'https://github.com/rafaeltuelho/jboss-kitchensink'

    stage 'Build project with Maven'
    echo 'Building project'
    def mvnHome = tool 'M3'
    def javaHome = tool 'jdk8'
    sh "${mvnHome}/bin/mvn package -Popenshift -DskipTests"

    stage 'Build image and deploy in Dev'
    echo 'Building docker image and deploying to Dev'
    buildKitchensink('kitchensink-dev')

    stage 'Automated tests'
    echo 'This stage simulates automated tests'
    //sh "${mvnHome}/bin/mvn -B -Dmaven.test.failure.ignore verify"
    sh "${mvnHome}/bin/mvn -B test -Parq-wildfly-embedded-Dmaven.test.failure.ignore verify"

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
def buildKitchensink(String project){
    projectSet(project)

    sh "cat ./osev3/docker/custom-eap7/Dockerfile | oc new-build --name=kitchensink --binary --strategy=docker -l app=kitchensink  -D - || echo 'Build exists'"
    sh "oc start-build kitchensink --from-dir=. --follow"
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
