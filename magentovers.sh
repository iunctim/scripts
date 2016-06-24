#!/bin/bash
# This script helps to determine the version of a magento web site 

if [ $# -ne 1 ]
then
        echo "Usage: ./magentovers.sh <path> (f.e.: >./magentovers.sh /var/www/test)"
   exit 1
fi

path=$1

cd $path > /dev/null
version=$( ./mage list-installed|egrep "Mage_All_Latest" | awk -F' ' '{print $2 " " $3}' )  
cd - > /dev/null

if [[ -n $version ]]; then	
	echo "$version"
else 
	echo "NO VERSION FOUND"
fi

