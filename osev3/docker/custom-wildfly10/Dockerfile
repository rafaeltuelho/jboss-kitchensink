FROM jboss/wildfly:latest

USER jboss
RUN ${JBOSS_HOME}/bin/add-user.sh admin jboss@123 --silent

#Mgmt tcp port
EXPOSE 9990 9999
#Debug tcp port
EXPOSE 8787

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0", "--debug"]
