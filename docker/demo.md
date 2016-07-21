# JBDS Docker Tooling

## References
 * [Basic Docker Tooling Configuration for JBoss Developer Studio 9.x and 10.x](https://access.redhat.com/articles/1488373)
 * [Using JBoss Developer Studio 10.x's Container Development Kit Tooling](https://access.redhat.com/articles/2388671)

## JBoss Kitchensink Demo

 * clone the kitchensink quickstart project repo
 ```
 git clone https://github.com/rafaeltuelho/jboss-kitchensink.git
 ```

 * import the project into JBDS Workspace as Maven Project

### Deploy into a Standalone EAP 7 Server
 * Project > Right Click > Run As > Run on a Server
 * Select the JBoss EAP 7 Server adapter
 * Stops the server

### Configure the Docker Tooling
 * Ensure you have the Docker Engine installed and the Daemon running on your system
 * Open your JBDS workspace
 * Press the Ctrl and 3 keys and in the Quick Access bar, start typing 'Docker Explorer'.
 * In the Docker Explorer View add a new connection
 * In a Linux box use the default Unix Socket (`unix:///var/run/docker.sock`)
 * Click `Test Connection`
 * You should see a `Ping Succeeded` message

### Pull a new Base Image
  * In the Docker Explorer View select `Images`
  * Right Click > Pull
   * Registry: `Docker Daemon Registry (Default)`
   * Name: `jboss/Wildfly`
  * Finish

### Deploy into a Docker Container
 * Open the `docker/Dockerfile`
 * Build the image
   * Dockerfile > Ricght Click > Run As > Docker Image Build
   * Choose your Docker daemon/engine connection
   * Inform the repo and image name (eg: `demos/mywildfly`)
   * Watch the docker build process through Console View
 * Using the Docker Explorer View
  * Select the `demos/mywildfly` image
  * Right Click > Run
  * Inform a name for your Container (rg: `mywildfly`)
  * Uncheck the option 'Publish all exposed ports to random ports...'
  * Check the 1st (`-i`) and 3rd (`--rm`) options
  * Finish
  * The server's log (from the Wildfly inatnace inside the Docker Contaienr) should appear on the Console View
 * Add a new Wildfly Server Adapter using the JBDS Server view
  * From Servers View
  * Right Click > New > Server
  * Choose the Wildfly 10.0 Adapter type
  * Next
  * Check:
    * The Server is > Remote
    * Controlled by: Managements Operations
    * Server lifecycle is externally managed
  * Uncheck
     * Assign a runtime to this server
  * Next
     * Remote Server Home: `/opt/jboss/wildfly`
  * Finish
  * Start the server adapter (can be in `debug` mode)
  * Deploy the kitchensink project into the server adapter!
  * Stops the Server adapter
  * Stops the Container

### Using a Postgres DB Conatiner
 * Pull the Official Postgres Docker image
 * Run a Postgres Container
   * Expose the `5432` TCP ports
   * Specify the credentials using env vars
 * Run your Wildfly conatiner linking it with the Postgres DB.
 * Change the jboss-kitchensink `persistence.xml` to use a PostgresDS
 ```
 ...
 <!-- jta-data-source>java:jboss/datasources/KitchensinkQuickstartDS</jta-data-source -->
 <jta-data-source>java:jboss/datasources/PostgresDS</jta-data-source>
 ...
 ```

### Creating a new app on Openshift from JBDS
 * Follow the instructions described here
  * [Debugging Java Applications using the Red Hat Container Development Kit](http://developerblog.redhat.com/2016/07/21/debugging-java-applications-using-the-red-hat-container-development-kit/)
  * TODO: condifgurar o BuildConfig do template eap64 para usar a variável de ambiente `MAVEN_MIRROR_URL` apontando para um Nexus.
