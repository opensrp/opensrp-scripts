#!/bin/sh

now="$(date +'%d_%m_%Y_%H_%M_%S')"
file_name="facility_activity_report_$now".csv
report_folder="~/etl"

sourceFile="$report_folder/$file_name"
destinationFile="etl/$file_name"

mysql -u etlMysqlUser -pXXXXXXX < ~/facility_activity_report_dml.sql

mysql -u etlMysqlUser -pXXXXXXX -e 'select * from path_zambia_etl.facility_activity_report' | sed  's/\t/,/g' > $sourceFile


export AWS_ACCESS_KEY_ID="XXXXXXX"
export AWS_SECRET_ACCESS_KEY="XXXXXXX"

duplicity --s3-use-new-style --no-encryption $sourceFile s3+http://opensrp/reports/$destinationFile

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SECRET_ACCESS_KEY