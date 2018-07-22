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
#echo "configure contom login modules using jboss-cli..."
#$JBOSS_HOME/bin/jboss-cli.sh --file=config-extension.cli
