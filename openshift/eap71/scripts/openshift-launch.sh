#!/bin/sh
# Openshift EAP launch script

echo -e "\n\n\n"
echo "This is a fork of the original $JBOSS_HOME/bin/openshift-launch.sh found in app source repo and copied to $HOME/app-scripts!!!"

# TERM signal handler
function clean_shutdown() {
  echo "*** JBossAS wrapper process ($$) received TERM signal ***"
  $JBOSS_HOME/bin/jboss-cli.sh -c ":shutdown(timeout=60)"
  wait $!
}

# call the xPaaS image's original runtime scripts (the same called during app Deployment)
echo "calling ${JBOSS_HOME}/bin/launch/openshift-common.sh"
source ${JBOSS_HOME}/bin/launch/openshift-common.sh

echo "calling ${JBOSS_HOME}/bin/launch/configure.sh"
source ${JBOSS_HOME}/bin/launch/configure.sh

echo -e "\n\n\n"
echo -e "------------------------------------------------------------------------\n"
echo -e "Before start the app I need to perform some custom configuration on EAP configuration (standalone-openshift.xml)..."
echo -e "\t to do that I'm going to use jboss-cli in offline mode (embedded-server)."
echo -e "------------------------------------------------------------------------\n"
echo -e "\n\n\n"
${JBOSS_HOME}/bin/jboss-cli.sh --file=$HOME/app-scripts/config-extension.cli

if [ "${SPLIT_DATA^^}" = "TRUE" ]; then
  source /opt/partition/partitionPV.sh

  DATA_DIR="${JBOSS_HOME}/standalone/partitioned_data"

  partitionPV "${DATA_DIR}" "${SPLIT_LOCK_TIMEOUT:-30}"
else
  #echo "$JBOSS_HOME/bin/launch/configure.sh already called by app's run script"
  #source $JBOSS_HOME/bin/launch/configure.sh

  echo "Running $JBOSS_IMAGE_NAME image, version $JBOSS_IMAGE_VERSION"

  trap "clean_shutdown" TERM

  if [ -n "$CLI_GRACEFUL_SHUTDOWN" ] ; then
    trap "" TERM
    echo "Using CLI Graceful Shutdown instead of TERM signal"
  fi

  $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -bmanagement 127.0.0.1 ${JAVA_PROXY_OPTIONS} ${JBOSS_HA_ARGS} ${JBOSS_MESSAGING_ARGS} &

  PID=$!
  wait $PID 2>/dev/null
  wait $PID 2>/dev/null
fi