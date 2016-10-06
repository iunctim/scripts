#!/bin/bash
# This script checks if the virtual host of a web site is set up and
# if the dns record routes to this server 

if [ $# -ne 2 ]
then
        echo "Usage: ./checkVHost.sh -a <path> (f.e.: >./checkVHost.sh -a /var/www/test)"
   exit 1
fi

option=""

while getopts ":abcd" opt; do
   case $opt in
      a)
         option="a" 
      ;;
      b)
         option="b" 
      ;;
      c)
         option="c" 
      ;;
      d)
         option="d" 
      ;;
      \?)
         exit 3         
      ;;
   esac
done

shift $((OPTIND - 1))

path="$1"
vhost=$(fgrep -lr "${path}" /etc/apache2/sites-enabled/* | head -n1)
domain=""
domainip=""

if [[ ! -z $vhost ]]; then
   domain=$(cat $vhost | grep "ServerName" | awk -F' ' '{print $2}' | head -n1)
   domainip=$(dig +short ${domain})
fi

case $option in
   a)
      if [[ -z $vhost ]]; then
         echo "NO ACTIVE VHOST"	
         exit 1
      fi

      serverips=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

      while read -r ip; do
         if [ "${ip}" = "${domainip}"  ];then
            echo "ONLINE"
            exit 0
         fi
      done <<< "$serverips"

      echo "OFFLINE"
      exit 2
   ;;
   b)
      if [[ -z $vhost ]]; then
         echo "000"	
         exit 1
      fi
      loaded=$(curl -sL -w "%{url_effective}" "${domain}" -o /dev/null)
      httpstatus=$(curl -sL -w "%{http_code}" "${loaded}" -o /dev/null)
      echo ${httpstatus}
      exit 0
   ;;
   c)
      if [[ -z $vhost ]]; then
         echo ""	
         exit 1
      fi
      loaded=$(curl -sL -w "%{url_effective}" "${domain}" -o /dev/null)
      echo ${loaded}
      exit 0
   ;;
   d)
      echo ${domainip}
      exit 0
   ;;
   *)
      exit 3         
   ;;
esac


