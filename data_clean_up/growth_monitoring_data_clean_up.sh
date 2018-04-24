#!/usr/bin/env bash
cleanDuplicateUUIDS(){

 local mysql_user=$1
 local mysql_pass=$2
 local mysql_database=$3

 export MYSQL_PWD=${mysql_pass}

#First remove all encounters not on couch
 mysql ${mysql_database} -u ${mysql_user} -s -N < /Users/ona/openSRP/path-zambia-etl/data_clean_up/void_encounters_not_in_couch.sql | while read uuid;
 do
    echo "UPDATE encounter SET voided = 1, voided_by = 1, date_voided = NOW(), void_reason ='GM encounter Not Found
    in OpenSRP' WHERE uuid = '${uuid}';" >>   void_encounters_not_in_couch.sql
 done

 # void duplicates
 mysql ${mysql_database} -u ${mysql_user} -s -N < /Users/ona/openSRP/path-zambia-etl/data_clean_up/get_duplicate_uuids.sql | while read uuids;
 do
    mysql ${mysql_database} -u ${mysql_user} -p${mysql_pass} -ss <<<"UPDATE encounter SET voided = 1, voided_by = 1,
    date_voided = NOW(),void_reason ='OpenSRP Duplicate Encounter' WHERE encounter_id IN (${uuids});"
  done

 unset MYSQL_PWD

}

cleanDuplicateUUIDS $1 $2 $3