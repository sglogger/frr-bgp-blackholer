#!/bin/sh

set -e

##
# For volume mounts...
##
/usr/sbin/crond -b -l 0 -L /var/log/frrlog.pipe

# execute original 
/usr/lib/frr/docker-start
