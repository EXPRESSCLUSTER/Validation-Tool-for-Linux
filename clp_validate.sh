#!/bin/sh
#
#         The Validation Tool for EXPRESSCLUSTER Linux Version
#
# This tool can be used for validation of EXPRESSCLUSTER configuration
# file(clp.conf).
#
# How to use
#
# 1. Put clp_validate.sh in your ECX system.
# 2. Execute chmod +x clp_validate.sh
# 3. Execute ./clp_validate.sh
#    If you have clp.conf of other system, you can supecify the file as below.
#    e.g.) Put clp.conf under /tmp before execute this command.
#          ./clp_validate.sh /tmp/clp.conf
#
#                                          Contact: tai-takemoto@sx.jp.nec.com
#


DEFAULTCONF="/opt/nec/clusterpro/etc/clp.conf"

if [ "X$1" = "X" ]
then
	CONF=$DEFAULTCONF
elif [ -f $1 ]
then
	CONF=$1
else
	CONF=$DEFAULTCONF
fi

ifconfig_check ()
{
	for IPADDR in `ifconfig | grep "inet " | awk '{print $2}'`
	do
		if [ "X$IPADDR" = "X$IFNAME" ]
		then
			return 0
		fi
	done

	return 1
}

ping_check ()
{
	RESULT=`ping $IFNAME -w 1 > /dev/null 2>&1`
	RETVAL=$?

	if [ $RETVAL -eq 0 ]
	then
		echo "  OK              : $IFNAME"
	elif [ $RETVAL -eq 1 ]
	then
		echo "  NG (Ping Error) : $IFNAME"
		ret_val=1
	fi
}

if_check ()
{
	echo
	echo "  [$SVNAME]"

	for IFNAME in `xmllint --xpath "/root/server[@name=\"$SVNAME\"]" $CONF | grep "<info>" | sed -e "s/<info>\(.*\)<\/info>/\1/" | cut -d "%" -f 1 | tr -d " "`
	do
		if [ "X$IFNAME" != "X" ]
		then

			if [ "X$SVNAME" = "X`hostname`" ]
			then
				ifconfig_check
				if [ $? -eq 0 ]
				then
					ping_check
				else
					echo "  NG (Exist?)     : $IFNAME"
					ret_val=1
				fi
			else
				ping_check
			fi
		fi
	done
}

server_check ()
{
	echo "Interconnect IP Address ping check..."

	for SVNAME in `xmllint --xpath "/root/server" $CONF | grep "<server name=" | cut -d "\"" -f 2`
	do
		if_check
	done

	echo "Done."
	echo
}


rsc_check ()
{
	xmllint --xpath "/root/resource/$RSCTYPE" $CONF > /dev/null 2>&1
	if [ $? -ne 0 ]
	then
#		echo "  There is no $RSCTYPE resource."
		return 1
	fi

	return 0
}

fip_check ()
{
	RSCTYPE=fip

	rsc_check
	if [ $? -ne 0 ]
	then
#		echo "Done."
#		echo
		return 0
	fi

	echo "FIP ping check..."

	for IPADDR in `xmllint --xpath "/root/resource/fip" $CONF | \
		grep "<ip>" | sed -e "s/<ip>\(.*\)<\/ip>/\1/" | \
		cut -d "%" -f 1 | tr -d " "`
	do
		ping $IPADDR -w 1 > /dev/null 2>&1

		if [ $? -eq 0 ]
		then
			echo "  NG (Exist)    : $IPADDR"
			ret_val=1
		else
			echo "  OK (Not Used) : $IPADDR"
		fi
	done

	echo "Done."
	echo
}

device_check ()
{
	for DEVICE in `xmllint --xpath "/root/resource/$RSCTYPE" $CONF | \
		grep "<$TAGNAME>" | sed -e "s/<$TAGNAME>\(.*\)<\/$TAGNAME>/\1/" | \
		cut -d "%" -f 1 | tr -d " "`
	do
		fdisk -l $DEVICE > /dev/null 2>&1

		if [ $? -eq 0 ]
		then
			echo "  OK (Exist)     : $DEVICE"
		else
			echo "  NG (Not Exist) : $DEVICE"
			ret_val=1
		fi
	done
}

disk_check ()
{
	RSCTYPE=disk

	rsc_check
	if [ $? -ne 0 ]
	then
#		echo "Done."
#		echo
		return 0
	fi

	echo "DISK device existence check..."

	TAGNAME="device"
	device_check

	echo "Done."
	echo
}

md_check ()
{
	RSCTYPE=md

	rsc_check
	if [ $? -ne 0 ]
	then
#		echo "Done."
#		echo
		return 0
	fi

	echo "MD device existence check..."

	TAGNAME="dppath"
	device_check

	TAGNAME="cppath"
	device_check

	echo "Done."
	echo
}

hd_check ()
{
	RSCTYPE=hd

	rsc_check
	if [ $? -ne 0 ]
	then
#		echo "Done."
#		echo
		return 0
	fi

	echo "HD device existence check..."

	TAGNAME="dppath"
	device_check

	TAGNAME="cppath"
	device_check

	echo "Done."
	echo
}

ret_val=0

echo "=================================================="
echo "  EXPRESSCLUSTER Validation Tool"
echo
echo "  Configuration File"
echo "  -> $CONF"
echo "=================================================="

server_check
fip_check
disk_check
md_check
hd_check

echo "=================================================="

exit $ret_val
