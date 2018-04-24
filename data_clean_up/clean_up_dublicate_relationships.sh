#!/usr/bin/env bash

readonly MYSQL_DATABASE=$1
readonly MYSQL_USER=$2;
readonly MYSQL_PASS=$3

cleanDuplicateRelationShips(){
 local OIFS=$IFS;
 IFS=",";

 #Get duplicates relationship ids.
 export MYSQL_PWD=${MYSQL_PASS}
 mysql_user="${MYSQL_USER}"
 mysql ${MYSQL_DATABASE} -u "${MYSQL_USER}" -s -N </Users/ona/openSRP/path-zambia-etl/data_clean_up/get_duplicate_relationships.sql | while read relationship_ids;
 do
 relationshipArray=(${relationship_ids})
    for ((i=0; i<${#relationshipArray[@]}; ++i));
    do
     updateRelationShips ${relationshipArray[$i]} 
    done
 done
 unset MYSQL_PWD
 IFS=$OIFS;
}

#perform the updates
function updateRelationShips(){
local relationshipID=$1
local OIFS=$IFS;
OIFS=$IFS;
IFS="\t";
PersonArray=$(mysql -u "${MYSQL_USER}" ${MYSQL_DATABASE} -s -e "select person_b,person_a from relationship where
relationship_id=${relationshipID} ")

for person in ${PersonArray}
do
   mother1=$(getMotherBaseID $(getZeirId $(getPersonID ${person} 1)))
   mother2=$(getMotherBaseID $(getZeirId $(getPersonID ${person} 2)))

   if [ "$mother1" == "$mother2" ];
   then
    echo "they are related.... move along"
   else
    mysql ${MYSQL_DATABASE} -u "${MYSQL_USER}" -ss <<<"UPDATE relationship SET voided = 1, voided_by = 1, date_voided = NOW(),void_reason ='Allocated Wrongly' WHERE relationship_id=${relationshipID};"
   fi
    echo "Voided... "${relationshipID}
done
IFS=$OIFS;
}

#get person ID from the relationship table
function getPersonID(){
local persons=$1
local count=$2
echo  ${persons} | awk '{ print $'"${count}"' }'
}

#get zeir id for the corresponding child
function getZeirId() {
local patient_id=$1
echo $(mysql ${MYSQL_DATABASE} -u "${MYSQL_USER}" -s -N -e "select identifier from patient_identifier where
patient_id='${patient_id}' and identifier_type =17")
}

#get mother base entity id for the corresponding child
function getMotherBaseID() {
local base1=$1
echo $(mysql ${MYSQL_DATABASE} -u "${MYSQL_USER}" -s -N -e "select mother_base_id from zeir_relations where zeir_id='${base1}'")
}

cleanDuplicateRelationShips $1 $2 $3