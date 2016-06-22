#!/bin/bash
# This script helps to determine the version of a wordpress web site 

if [ $# -ne 1 ]
then
        echo "Usage: ./wordpressvers.sh <path> (f.e.: >./wordpressvers.sh /var/www/test)"
   exit 1
fi

path=$1

version=$( cat ${path}/wp-includes/version.php | grep 'wp_version =' | head -n1 | awk -F";|=|'" '{print $3}'  )  

if [[ -n $version ]]; then	
	echo "$version"
else 
	echo "NO VERSION FOUND"
fi

