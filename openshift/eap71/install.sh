#!/bin/bash

injected_dir=$1
source /usr/local/s2i/install-common.sh
# no additional deployments here
#install_deployments ${injected_dir}/injected-deployments.war
#to system/layers/openshift/
install_modules ${injected_dir}/modules
configure_drivers ${injected_dir}/drivers.env