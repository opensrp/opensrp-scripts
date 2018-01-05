#!/usr/bin/env bash
directory="/usr/share/tomcat7/.OpenMRS/patient_images/"
mysql_pass="h2JAhYMy6Ek3chyphq3zpAMgrmVfuSBCFSQy2wW4NwrH2NQQea"
mysql_user="root"
extension=".jpg"

patient_identifiers=(`find $directory -maxdepth 1 -iname '*.jpg' -or -iname '*.png'  |sed 's#.*/##' | sed 's/\.jpg$//1'`)
for i in "${patient_identifiers[@]}"
do :
person_id=$(mysql openmrs -u $mysql_user -p$mysql_pass -ss <<<"SELECT patient_id from patient_identifier where identifier='$i'" )
if [ ${person_id:+1} ]
then
person_attribute_id=$(mysql openmrs -u $mysql_user -p$mysql_pass -ss <<<"SELECT person_attribute_id from person_attribute where person_id='$person_id' and person_attribute_type_id='29';" )
if [ ${person_attribute_id:+1} ]
then
mysql openmrs -u $mysql_user -p$mysql_pass -ss <<<"UPDATE person_attribute SET value='$i$extension' WHERE person_attribute_id='$person_attribute_id';"
else
mysql openmrs -u $mysql_user -p$mysql_pass -ss <<<"INSERT INTO person_attribute (person_id, value, person_attribute_type_id, creator) VALUES ('$person_id', '$person_id$extension', '29', '1');"
fi
fi
done
