#!/bin/bash
generateEncounterEtl() {
  local pathToScripts=$1
  local mysqlUser=$2
  local mysqlPassword=$3
  local reportLife=$4
  local slackChannel=$5
  local slackToken=$6

  cd $pathToScripts

  now="$(date +'%d_%m_%Y')"
  file_name="facility_stock_activity".csv
  report_folder="./etl"
  sourceFile="$report_folder/$file_name"
  destinationFile="etl/$file_name"

  mkdir -p $report_folder
  find $report_folder -mtime +$reportLife -exec rm {} \;
  export PGPASSWORD="XXXXXXXXXXXXXXXX"
  psql -h localhost -d opensrp -U $mysqlUser -c "COPY ($(<./stock_indicator_query.sql)) TO STDOUT WITH CSV HEADER DELIMITER ','; " > $sourceFile
  unset PGPASSWORD
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  /usr/bin/aws s3 sync $report_folder s3://opensrp/reports/etl --acl public-read --delete
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

}

generateEncounterEtl $1 $2 $3 $4 $5 $6

