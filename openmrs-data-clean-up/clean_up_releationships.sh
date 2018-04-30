#!/usr/bin/env bash
cleanWrongRelationships(){

 local mysql_user=$1
 local mysql_pass=$2
 local mysql_database=$3

 export MYSQL_PWD=${mysql_pass}

#Void all relationships Wrongly Allocated
 mysql ${mysql_database} -u ${mysql_user} -s -N < /Users/ona/jtech/path-zambia-etl/openmrs-data-clean-up/clean_up_releationships.sql | while read relationship_id;
 do
    echo "UPDATE relationship SET voided = 1, voided_by = 1, date_voided = NOW(), void_reason ='Wrongly Allocated' WHERE relationship_id = '${relationship_id}';" >>   /tmp/void_relationships_not_in_couch.sql

 done
 unset MYSQL_PWD

}

cleanWrongRelationships $1 $2 $3