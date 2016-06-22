#!/bin/bash
# This script helps to determine the version of a typo3 web site 

if [ $# -ne 1 ]
then
        echo "Usage: ./typo3vers.sh <path> (f.e.: >./typo3vers.sh /var/www/test)"
   exit 1
fi

path=$1

str=$( cat ${path}/typo3_src/ChangeLog | grep 'RELEASE' | head -n1 )  
regex='TYPO3 ([A-Z0-9.]+) '

[[ $str =~ $regex ]]

version=${BASH_REMATCH[1]}

if [[ -n $version ]]; then	
	echo "$version"
else 
	echo "NO VERSION FOUND"
fi

