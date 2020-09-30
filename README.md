# frr-bgp-blackholer
BGP Blackhole Service

## Configuration/Installation ##
### Cisco Router ###
please check `cisco-config.cfg` as reference how to implement this to your cisco router.

### Blackhole Service ###
once the container is running adapt via `vtysh` the bgp configuration on your container so you can talk to cisco router


### Blackhole Services ###
check `./data/update_filter.sh`, where you can specify which blacklists to be processed:

```
...
PROCESS_BOGONS=yes
INPUT_BOGONS=https://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt
OUTPUT_BOGONS=$GETDIR/bogons.txt

PROCESS_DSHIELD=yes
INPUT_DSHIELD=http://feeds.dshield.org/block.txt
OUTPUT_DSHIELD=$GETDIR/dshield.txt

PROCESS_CINS=no
INPUT_CINS=http://cinsscore.com/list/ci-badguys.txt
OUTPUT_CINS=$GETDIR/cins.txt

PROCESS_IPSPAM=yes
INPUT_IPSPAM=http://www.ipspamlist.com/public_feeds.csv
OUTPUT_IPSPAM=$GETDIR/ipspam.txt

PROCESS_MANUAL=no
INPUT_MANUAL=manual.txt

PROCESS_EXCEPTIONS=yes
INPUT_EXCEPTIONS=exceptions.txt
...
```

you can also define own prefix to filter out in the `manual.txt` file and specify such you want to exclude in the `execptions.txt` file (execption leads to a `no ip route ...` statement).



## Issues / Optimization Potential ##
Now the cron will remove all routers and re-add the new/existing ones every hour. I will improve it by working with incremental updates
