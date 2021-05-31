#!/bin/bash

IFS=$'\n'
cd /data
OUTPUT=/data/frr-input.txt
## for python db
OUTPUT_EXIST=/data/exist.txt
OUTPUT_ADD=/data/dbimport.txt
OUTPUT_WHITE=/data/dbwhite.txt

GETDIR=/data/get
AGE=45		# in mins

PROCESS_BOGONS=yes
INPUT_BOGONS=https://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt
OUTPUT_BOGONS=$GETDIR/bogons.txt

PROCESS_DSHIELD=yes
INPUT_DSHIELD=http://feeds.dshield.org/block.txt
OUTPUT_DSHIELD=$GETDIR/dshield.txt

# too large file!
PROCESS_CINS=no
INPUT_CINS=http://cinsscore.com/list/ci-badguys.txt
OUTPUT_CINS=$GETDIR/cins.txt

PROCESS_IPSPAM=yes
INPUT_IPSPAM=http://www.ipspamlist.com/public_feeds.csv
OUTPUT_IPSPAM=$GETDIR/ipspam.txt

PROCESS_MANUAL=yes
INPUT_MANUAL=manual.txt

PROCESS_EXCEPTIONS=yes
INPUT_EXCEPTIONS=exceptions.txt

cidr2mask() {
  local i mask=""
  local full_octets=$(($1/8))
  local partial_octet=$(($1%8))

  for ((i=0;i<4;i+=1)); do
    if [ $i -lt $full_octets ]; then
      mask+=255
    elif [ $i -eq $full_octets ]; then
      mask+=$((256 - 2**(8-$partial_octet)))
    else
      mask+=0
    fi
    test $i -lt 3 && mask+=.
  done

  echo -n $mask
}


## main ##

date
echo "getting bgp/routing data..."
#populate routing table
route -ne | grep lo$ | awk '{print "no ip route " $1 " " $3 " Null0" }' > $OUTPUT
route -ne | grep lo$ | awk '{print $1 " " $3 }' > $OUTPUT_EXIST


#================================================================
# BOGONS
if [[ "$PROCESS_BOGONS" == "yes"  ]]; then
	if [[ $(find "$OUTPUT_BOGONS" -mmin $AGE -print) ||  ! -f $OUTPUT_BOGONS ]]; then
		echo "BOGONS:getting $INPUT_BOGONS ..."
		wget -q $INPUT_BOGONS -O $OUTPUT_BOGONS
	else 
		echo "BOGONS: too young/disabled - not fetching"
	fi
	
	echo "processing: BOGONS"
	GNA=`grep "^[^#]" $OUTPUT_BOGONS`
	for LINE in $GNA; do
	        NET=`echo $LINE | awk -F/ '{print $1}'`;
	        MASK=`echo $LINE | awk -F/ '{print $2}'`;
	        echo -n "ip route $NET " >> $OUTPUT
	        cidr2mask $MASK >> $OUTPUT
	        echo -n " Null0" >> $OUTPUT
	        echo "" >> $OUTPUT

		#python db
	        echo -n "$NET " >> $OUTPUT_ADD
	        cidr2mask $MASK >> $OUTPUT_ADD
	        echo "" >> $OUTPUT_ADD
	done
else
	echo "not processing BOGONS"
fi
echo ""


#================================================================
# DSHIELD
if [[ "$PROCESS_DSHIELD" == "yes"  ]]; then
	if [[ $(find "$OUTPUT_DSHIELD" -mmin $AGE -print) ||  ! -f $OUTPUT_DSHIELD ]]; then
		echo "DSHIELD:getting $INPUT_DSHIELD ..."
		wget -q $INPUT_DSHIELD -O $OUTPUT_DSHIELD
	else 
		echo "DSHIELD: too young/disabled - not fetching"
	fi
	
	echo "processing: DSHIELD"

	GNA=`grep "^[^#][0-9].*" $OUTPUT_DSHIELD`
	for LINE in $GNA; do
	        NET=`echo $LINE | awk '{print $1}'`;
	        MASK=`echo $LINE | awk '{print $3}'`;
	        echo -n "ip route $NET " >> $OUTPUT
	        cidr2mask $MASK >> $OUTPUT
	        echo -n " Null0" >> $OUTPUT
	        echo "" >> $OUTPUT

		#python db
	        echo -n "$NET " >> $OUTPUT_ADD
	        cidr2mask $MASK >> $OUTPUT_ADD
	        echo "" >> $OUTPUT_ADD
	done
else
	echo "not processing DSHIELD"
fi
echo ""


#================================================================
# CINS
if [[ "$PROCESS_CINS" == "yes"  ]]; then
	if [[ $(find "$OUTPUT_CINS" -mmin $AGE -print) ||  ! -f $OUTPUT_CINS ]]; then
		echo "CINS:getting $INPUT_CINS ..."
		wget -q $INPUT_CINS -O $OUTPUT_CINS
	else 
		echo "CINS: too young/disabled - not fetching"
	fi
	
	echo "processing: CINS"
	sed -i 's/$/ 32/g' $OUTPUT_CINS

	GNA=`grep "^[^#][0-9].*" $OUTPUT_CINS`
	for LINE in $GNA; do
	        NET=`echo $LINE | awk '{print $1}'`;
	        MASK=`echo $LINE | awk '{print $2}'`;
	        echo -n "ip route $NET " >> $OUTPUT
	        cidr2mask $MASK >> $OUTPUT
	        echo -n " Null0" >> $OUTPUT
	        echo "" >> $OUTPUT

		#python db
	        echo -n "$NET " >> $OUTPUT_ADD
	        cidr2mask $MASK >> $OUTPUT_ADD
	        echo "" >> $OUTPUT_ADD
	done
else
	echo "not processing CINS"
fi
echo ""


#================================================================
# IPSPAM
if [[ "$PROCESS_IPSPAM" == "yes"  ]]; then
	if [[ $(find "$OUTPUT_IPSPAM" -mmin $AGE -print) ||  ! -f $OUTPUT_IPSPAM ]]; then
		echo "IPSPAM:getting $INPUT_IPSPAM ..."
		wget -q $INPUT_IPSPAM -O $OUTPUT_IPSPAM
	else 
		echo "IPSPAM: too young/disabled - not fetching"
	fi
	
	echo "processing: IPSPAM"

	GNA=`grep "^[^#]" $OUTPUT_IPSPAM`
	for LINE in $GNA; do
	        NET=`echo $LINE | awk -F, '{print $3}'`;
		MASK="32";
	        echo -n "ip route $NET " >> $OUTPUT
	        cidr2mask $MASK >> $OUTPUT
	        echo -n " Null0" >> $OUTPUT
	        echo "" >> $OUTPUT

		#python db
	        echo -n "$NET " >> $OUTPUT_ADD
	        cidr2mask $MASK >> $OUTPUT_ADD
	        echo "" >> $OUTPUT_ADD
	done
else
	echo "not processing IPSPAM"
fi
echo ""


#================================================================
# MANUAL
if [[ "$PROCESS_MANUAL" == "yes"  || ! -f $INPUT_MANUAL ]]; then
	echo "processing: MANUAL"

	GNA=`grep "^[^#]" $INPUT_MANUAL`
	for LINE in $GNA; do
	        NET=`echo $LINE | awk -F "/" '{print $1}'`;
	        MASK=`echo $LINE | awk -F "/" '{print $2}'`;
	        echo -n "ip route $NET " >> $OUTPUT
	        cidr2mask $MASK >> $OUTPUT
	        echo -n " Null0" >> $OUTPUT
	        echo "" >> $OUTPUT

		#python db
	        echo -n "$NET " >> $OUTPUT_ADD
	        cidr2mask $MASK >> $OUTPUT_ADD
	        echo "" >> $OUTPUT_ADD
	done
else
	echo "not processing MANUAL"
fi
echo ""


#================================================================
# EXCEPTIONS
if [[ "$PROCESS_EXCEPTIONS" == "yes"  || ! -f $INPUT_EXCEPTIONS ]]; then
	echo "processing: EXCEPTIONS"

	GNA=`grep "^[^#]" $INPUT_EXCEPTIONS`
	for LINE in $GNA; do
	        NET=`echo $LINE | awk -F "/" '{print $1}'`;
	        MASK=`echo $LINE | awk -F "/" '{print $2}'`;
		# special >> NO ip route
	        echo -n "no ip route $NET " >> $OUTPUT
	        cidr2mask $MASK >> $OUTPUT
	        echo -n " Null0" >> $OUTPUT
	        echo "" >> $OUTPUT

		#python db
	        echo -n "$NET " >> $OUTPUT_WHITE
	        cidr2mask $MASK >> $OUTPUT_WHITE
	        echo "" >> $OUTPUT_WHITE
	done
else
	echo "not processing EXCEPTIONS"
fi
echo ""

# update router
