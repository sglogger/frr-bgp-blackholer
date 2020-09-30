# FRR configuration

These are the upstram configuration files for FRR.
When instantiated, these files are copied over to the runtime environment at /data/docker/frr-ospf.

Maintance or deployment of these files is taken care for by ansible.


 | FILENAME                     | PURPOSE                                   |
 | ---------------------------- | ----------------------------------------- |
 | daemons                      | FRR config for enabled/disabled daemons   |
 | ---------------------------- | ----------------------------------------- |
 | frr.conf.jj2                 | ansible-maintained Jinja2 config template |
 | ---------------------------- | ----------------------------------------- |
 | support_bundle_commands.conf | configuration for "show tech"             |
 | ---------------------------- | ----------------------------------------- |
 | vtysh.conf                   | vtysh.sh configuration                    |

