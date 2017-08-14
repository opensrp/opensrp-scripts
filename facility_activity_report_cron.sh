#!/bin/bash
generateEtl() {
  local pathToScripts=$1
  local mysqlUser=$2
  local mysqlPassword=$3
  local slackChannel=$4
  local slackToken=$5
  local reportLife=$6

  cd $pathToScripts

  now="$(date +'%d_%m_%Y')"
  file_name="facility_activity_report_$now".csv
  report_folder="./etl"
  sourceFile="$report_folder/$file_name"
  destinationFile="etl/$file_name"

  mkdir -p $report_folder
  find $report_folder -mtime +$reportLife -exec rm {} \;
  /usr/bin/mysql -u $mysqlUser -p$mysqlPassword < ./facility_activity_report_dml.sql
  /usr/bin/mysql -u $mysqlUser -p$mysqlPassword -e 'select * from path_zambia_etl.facility_activity_report' | sed  's/\t/,/g' > $sourceFile
  /usr/bin/aws s3 sync $report_folder s3://opensrp/reports/etl --acl public-read --delete
  /usr/bin/curl -F username="PATH Zambia ETL" -F text="https://s3.amazonaws.com/opensrp/reports/$destinationFile" -F channel=$slackChannel -F token="$slackToken" https://slack.com/api/chat.postMessage
}

generateEtl $1 $2 $3 $4 $5 $6
