#!/bin/bash
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

#files
TEAMFILE="$BASEDIR/data/$(date +%Y)_team_names.txt"
SCHEDULEDIR="$BASEDIR/schedules/$(date +%Y)"

mkdir -p "$BASEDIR/zips"
ZIPFILE="$BASEDIR/zips/$(date +%Y)_milb_schedule_org_files.zip"

if [[ ! -f "$TEAMFILE" ]]; then
    echo "Error: $TEAMFILE does not exist" 2>&1
    exit 1
fi

GAWKBIN="$(which gawk)"
if [[ "$GAWKBIN" == "" ]]; then
    echo "Error: 'gawk' is not available. Please install it." 2>&1
    exit 1
fi

mkdir -p "$SCHEDULEDIR"
cd "$SCHEDULEDIR"

for team in $(cat $TEAMFILE); do

    #fetch the iCal file if necessary
    if [[ ! -f "$SCHEDULEDIR/milb-${team}.ics" ]]; then
	wget "https://www.stanza.co/api/schedules/milb-${team}/milb-${team}.ics"
    fi

    #then convert it to org
    "$GAWKBIN" -f "$BASEDIR/scripts/ical2org_fixed.awk" < "$SCHEDULEDIR/milb-${team}.ics" > "$SCHEDULEDIR/milb-${team}.org"
    
done

zip -r "$ZIPFILE" *.org
rm "$SCHEDULEDIR"/*.ics
