#!/bin/bash

echo "Executing install script found in $1 ..."
injected_dir=$1
source /usr/local/s2i/install-common.sh

echo "Copying configuration..."
copy_injected ${install_dir}/configuration $JBOSS_HOME/standalone/configuration
echo "Copying jboss custom modules..."
install_modules ${injected_dir}/modules
echo "Configuring JDBC drivers..."
configure_drivers ${injected_dir}/drivers.env