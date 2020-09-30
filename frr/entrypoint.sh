#!/bin/sh

set -e

##
# For volume mounts...
##
/usr/sbin/crond -b

# execute original 
/usr/lib/frr/docker-start
