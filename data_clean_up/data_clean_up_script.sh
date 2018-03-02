#!/usr/bin/env bash
cleanDuplicateUUIDS(){

 local mysql_user=$1
 local mysql_pass=$2
 COUNTER=0
 mysql openmrs -u $mysql_user -p$mysql_pass -s -N < /Users/ona/openSRP/path-zambia-etl/data_clean_up/get_duplicate_uuids.sql | while read uuids; do
    let COUNTER=COUNTER+1
    echo "cleaning.... $COUNTER"
    mysql openmrs -u $mysql_user -p$mysql_pass -ss <<<"UPDATE encounter SET voided = 1, voided_by = 1, date_voided = NOW(),
         void_reason ='OpenSRP Duplicate Encounter' WHERE encounter_id IN ($uuids) AND uuid NOT IN (SELECT uuid FROM event_uuids);"
done

}

cleanDuplicateUUIDS $1 $2
