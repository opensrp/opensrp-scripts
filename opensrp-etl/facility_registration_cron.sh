#!/bin/bash
generateRegistrationEtl() {
  local pathToScripts=$1
  local mysqlUser=$2
  local mysqlPassword=$3
  local reportLife=$4
  local slackChannel=$5
  local slackToken=$6

  cd $pathToScripts

  now="$(date +'%d_%m_%Y')"
  file_name="facility_registration_report_$now".csv
  report_folder="./etl"
  sourceFile="$report_folder/$file_name"
  destinationFile="etl/$file_name"

  mkdir -p $report_folder
  find $report_folder -mtime +$reportLife -exec rm {} \;
  export PGPASSWORD="XXXXXX"
  psql -h localhost -d opensrp -U $mysqlUser -f ./registrations_indicator_query.sql
  psql -h localhost -d opensrp -U $mysqlUser -c "COPY ($(<./facility_registration_query.sql)) TO STDOUT WITH CSV HEADER DELIMITER ','; " > $sourceFile
  unset PGPASSWORD
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  /usr/bin/aws s3 sync $report_folder s3://XXX/XX/X --acl public-read --delete
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

}

generateRegistrationEtl $1 $2 $3 $4 $5 $6


