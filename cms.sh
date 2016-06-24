#!/bin/bash
# This script helps to determine the kind of web site in a
# folder of web sites

if [ $# -ne 1 ]
then
        echo "Usage: ./cms.sh <path> (f.e.: >./cms.sh /var/www)"
   exit 1
fi

path=$1

BLUE=$'\033[0;34m'
PURPLE=$'\033[0;35m'
BROWN=$'\033[0;33m'
RED=$'\033[1;31m'
WHITE=$'\e[97m'
NC=$'\033[0m' # No Color

#background color
BG_RED=$'\e[41m'


# '' = right-align , '-' = left-align
ALIGN='-'
#width of the first column
INDENT='60'

repeat() {
 str=$1
 num=$2
 v=$(printf "%-${num}s" "$str")
 echo "${v// /${str}}"
}

#check if there any subdirectories at all and get the count
vhostCnt=$(find $path -mindepth 1 -maxdepth 1 -type d | wc -l)
onlineCnt="0"
offlineCnt="0"
inactiveCnt="0"

if [ "$vhostCnt" -le "0" ]; then
	echo "No subdirectories with containing vhosts in this directory!"
	exit
fi


printf "%s%s%${ALIGN}${INDENT}s \t\t\t %-30s \t\t %-15s %s \n" "${BG_RED}" "${WHITE}" "Web Site" "Version" "Status" "${NC}" 
repeat "-" "${INDENT}"

for dir in ${path}/*; do
	[ -d "${dir}" ] || continue	

	dirname=$(basename ${dir})
	cms=""
	
	onlinestatus="N/A"
	#check onlinestatus with checkVHost.sh 
	if [ -f "./checkVHost.sh" ]; then
		onlinestatus=$( ./checkVHost.sh ${dir} )

		case "$?" in 
		
				0) ((onlineCnt=onlineCnt + 1)) 
					;;
				1) ((inactiveCnt=inactiveCnt + 1)) 
					;;
				2) ((offlineCnt=offlineCnt + 1)) 
					;;
				*)  ;;

		esac
	fi
	
	color=$RED

	#check for typo3
	if [[ -n $(find ${dir} -maxdepth 0 -type d -exec test -e "{}/typo3" ';' -print) ]]; then 

		version=""
		#check the typo3 version, with typo3vers.sh
		if [ -f "./typo3vers.sh" ]; then
			version=$( ./typo3vers.sh ${dir} )
		fi
		
		cms="TYPO3 ($version)"
		color=$PURPLE
		
	#check for magento
	elif [[ -n $(find ${dir} -maxdepth 0 -type d -exec test -e "{}/app" ';' -print) ]]; then 

		version=""
		#check the magento version, with magentovers.sh
		if [ -f "./magentovers.sh" ]; then
			version=$( ./magentovers.sh ${dir} )
		fi

		cms="MAGENTO ($version)"
		color=$BROWN

	#check for wordpress
	elif [[ -n $(find ${dir} -maxdepth 0 -type d -exec test -e "{}/wp-includes" ';' -print) ]]; then 

		version=""
		#check the wordpress version, with wordpressvers.sh
		if [ -f "./wordpressvers.sh" ]; then
			version=$( ./wordpressvers.sh ${dir} )
		fi

		cms="WORDPRESS ($version)"
		color=$BLUE

	#else it is static HTML
	else

		cms="STATIC"

	fi

	printf "%${ALIGN}${INDENT}s \t\t\t %s %-30s %s \t\t %-15s \n" "${dirname}" "$color" "${cms}" "$NC" "${onlinestatus}" 
	repeat "-" "${INDENT}"

done

printf "\n%-s VHosts found!\n" "${vhostCnt}"
printf "\n%-s VHosts online\n" "${onlineCnt}"
printf "\n%-s VHosts inactive\n" "${inactiveCnt}"
printf "\n%-s VHosts offline\n" "${offlineCnt}"

