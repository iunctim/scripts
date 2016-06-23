#!/bin/bash
# This script checks if the virtual host of a web site is set up and
# if the dns record routes to this server 

if [ $# -ne 1 ]
then
        echo "Usage: ./checkVHost.sh <path> (f.e.: >./checkVHost.sh /var/www/test)"
   exit 1
fi

path=$1

vhost=$(fgrep -lr "${path}" /etc/apache2/sites-enabled | head -n1)

if [[ -z $vhost ]]; then
	echo "NO ACTIVE VHOST"	
	exit
fi

domain=$(cat $vhost | grep "ServerName" | awk -F' ' '{print $2}' | head -n1)

domainip=$(dig +short ${domain})

serverips=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

while read -r ip; do
	if [ "${ip}" = "${domainip}"  ];then
		echo "ONLINE"
		exit
	fi
done <<< "$serverips"

echo "OFFLINE"
exit
