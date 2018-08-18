#!/bin/bash

echo "Executing install script found in $1 ..."
injected_dir=$1
source /usr/local/s2i/install-common.sh

#echo "Copying configuration..."
#cp -v ${injected_dir}/configuration/* $JBOSS_HOME/standalone/configuration
echo "Copying jboss custom modules..."
install_modules ${injected_dir}/modules
echo "Configuring JDBC drivers..."
configure_drivers ${injected_dir}/drivers.env

echo "Copying custom scripts..."
mkdir -v $HOME/app-scripts
cp -v ${injected_dir}/scripts/* $HOME/app-scripts/
chmod a+x $HOME/app-scripts/*

echo "Copy jsf-injection jars..."
#mkdir -p $JBOSS_HOME/modules/system/layers/openshift/org/jboss/as/jsf-injection
find $JBOSS_HOME/modules -type d -name "wildfly-jsf-injection*.jar" \
 -exec cp {}/*.jar $JBOSS_HOME/modules/system/layers/openshift/org/jboss/as/jsf-injection/ \;

find $JBOSS_HOME/modules -type f -name "weld-core-jsf*.jar" \
 -exec cp {} $JBOSS_HOME/modules/system/layers/openshift/org/jboss/as/jsf-injection/ \;
