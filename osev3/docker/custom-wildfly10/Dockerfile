FROM jboss/wildfly:10.0.0.Final

# following the instructions described in 'https://docs.openshift.com/enterprise/3.2/creating_images/guidelines.html#use-uid'
USER root
RUN chgrp -R 0 /opt/jboss
RUN chmod -R g+rw /opt/jboss
RUN find /opt/jboss -type d -exec chmod g+x {} +

USER jboss
RUN ${JBOSS_HOME}/bin/add-user.sh admin jboss@123 --silent

#Mgmt tcp port
EXPOSE 9990 9999
#Debug tcp port
EXPOSE 8787

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0", "--debug"]
