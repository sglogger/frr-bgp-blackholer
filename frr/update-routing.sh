#!/bin/bash

echo "Updated Routing Information"
/usr/bin/vtysh -f /etc/frr/frr-input.txt
