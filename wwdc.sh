#!/bin/sh
# WWDC Video Downloader
# By Don Southard aka @dirtdon
#
# Usage Example:
#
# Download HD version of session 101 from WWDC 2015 
# ./wwdc.sh -y 2015 -f HD -s 101
#
# Download all SD videos from WWDC 2013
# ./wwdc.sh -y 2013 -f SD
#
# Download all HD videos from WWDC 2015
# ./wwdc.sh -y 2015
#
# Output all video URLs for 2015 HD Videos to a file
# Useful if you want to import a file of URLs to Synology Download Station :)
# ./wwdc.sh -y 2015 -u >> /Users/Name/Desktop/videos.txt

main () {
    getOptions $@
    fetchSessions
}

getOptions () {
	if [[ $# == 0 ]]; then
		printHelp
	fi
	while getopts ":hf:y:uo:s:" opt; do
		case $opt in
		    y)
		       	export WWDC_YEAR="wwdc$OPTARG"
				;;
			h)
				printHelp
				exit 0
				;;
			f)
				export WWDC_FORMAT=$(echo $OPTARG | tr '[:lower:]' '[:upper:]')
				;;
			u)
				export SESSION_URL_ONLY=true
				;;
			o)
				export SESSION_DOWNLOAD_PATH="$OPTARG"
				;;
			s)
				export SPECIFIC_SESSION="$OPTARG"
				;;
		    \?)
		    	echo "Invalid option: -$OPTARG"
		    	echo ""
		    	printHelp
		    	;;
		    :)
		    	echo "Option -$OPTARG requires an argument."
		    	echo ""
		    	printHelp
		    	exit 1
		    	;;  
	    esac
    done
}

fetchSessions () {
	DEV_URL="https://developer.apple.com"
	TMP_PROCESSING=(`curl -s "$DEV_URL/videos/$WWDC_YEAR/" | grep "videos/play/wwdc" |  awk -F \" '{print $(2)}'`)
	UNIQUE_SESSIONS=($(printf "%s\n" "${TMP_PROCESSING[@]}" | sort | uniq -c | awk '{ print $2 }'))
	for session in "${UNIQUE_SESSIONS[@]}"
	do 
		FORMAT="HD"
		if [[ $WWDC_FORMAT ]] && ([[ "$WWDC_FORMAT" == "HD" ]] || [[ "$WWDC_FORMAT" == "SD" ]]); then
			FORMAT=$WWDC_FORMAT
		fi

		SESSION_VIDEO_URL=$(curl -s $DEV_URL$session | grep "$FORMAT Video" |  awk -F \" '{print $(2)}' | sed "s/?dl=1//")

		if [[ "$SPECIFIC_SESSION" ]]; then
			SESSION_ID=$(echo "$SESSION_VIDEO_URL" | awk -F \/ '{print $(8)}')
			if [[ "$SESSION_ID" == "$SPECIFIC_SESSION" ]]; then
				processSession "$SESSION_VIDEO_URL"
				exit
			fi
		else 
			processSession "$SESSION_VIDEO_URL"
		fi

	done
}

processSession () {
	SESSION_VIDEO_URL=$1
	if [[ "$SESSION_URL_ONLY" ]]; then
	 	echo "$SESSION_VIDEO_URL"
	else
		if [[ "$SESSION_DOWNLOAD_PATH" ]]; then
		 	cd "$SESSION_DOWNLOAD_PATH" && curl "$SESSION_VIDEO_URL" -o "`basename $SESSION_VIDEO_URL`"
		else 
			curl "$SESSION_VIDEO_URL" -o `basename $SESSION_VIDEO_URL`
		fi
	fi
}

printHelp () {
	echo "WWDC Session Video Downloader"
	echo "Usage: wwdc.sh -y 2015 -f HD -o /Home/User/Desktop" 
	echo "Options:"
	echo "\t-y\t\tVideos from a specific WWDC year."
	echo "\t-f\t\tVideo format. e.g. HD or SD. Default HD"
	echo "\t-u\t\tOutput session URLs only. No videos downloaded"
	echo "\t-o\t\Path to where the videos will be downloaded. e.g. /Home/User/Desktop"
	echo "\t-s\t\Specific session number to download. e.g. 102"
}

main $@