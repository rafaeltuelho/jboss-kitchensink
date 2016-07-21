FROM jboss/wildfly:latest

USER jboss
RUN ${JBOSS_HOME}/bin/add-user.sh admin jboss@123 --silent

#Add Postgres JDBC Driver
COPY postgresql*.jar /tmp/
COPY add-jdbc-driver.cli /tmp/
RUN ${JBOSS_HOME}/bin/jboss-cli.sh --file=/tmp/add-jdbc-driver.cli

#Add Keycloak adapter
COPY keycloak-*-adapter*.zip /tmp/
#OIDC adapter
RUN unzip -uo /tmp/keycloak-wildfly-adapter*.zip -d ${JBOSS_HOME}
WORKDIR ${JBOSS_HOME}/bin
RUN ${JBOSS_HOME}/bin/jboss-cli.sh --file=adapter-install-offline.cli

#Mgmt tcp port
EXPOSE 9990
#Debug tcp port
EXPOSE 8787

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0", "--debug"]