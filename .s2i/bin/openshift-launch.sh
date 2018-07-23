#!/bin/sh
# Openshift EAP launch script

source ${JBOSS_HOME}/bin/launch/openshift-common.sh

echo -e "\n\n"
echo "This is a fork of the original $JBOSS_HOME/bin/openshift-launch.sh found in app source repo (.s2i directory)!!!"

# TERM signal handler
function clean_shutdown() {
  echo "*** JBossAS wrapper process ($$) received TERM signal ***"
  $JBOSS_HOME/bin/jboss-cli.sh -c ":shutdown(timeout=60)"
  wait $!
}

if [ "${SPLIT_DATA^^}" = "TRUE" ]; then
  source /opt/partition/partitionPV.sh

  DATA_DIR="${JBOSS_HOME}/standalone/partitioned_data"

  partitionPV "${DATA_DIR}" "${SPLIT_LOCK_TIMEOUT:-30}"
else
  echo "$JBOSS_HOME/bin/launch/configure.sh already called by app's run script"
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