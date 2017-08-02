#!/bin/bash
generateEtl() {
  # $1 - Path to ETL scripts
  # $2 - MySQL user
  # $3 - MySQL password
  # $4 - Slack channel to post message
  # $5 - Slack token to use
  # $6 - Report life in days
  cd $1

  now="$(date +'%d_%m_%Y_%H_%M_%S')"
  file_name="facility_activity_report_$now".csv
  report_folder="./etl"
  sourceFile="$report_folder/$file_name"
  destinationFile="etl/$file_name"

  mkdir -p $report_folder
  find $report_folder -mtime +$6 -exec rm {} \;
  /usr/bin/mysql -u $2 -p$3 < ./facility_activity_report_dml.sql
  /usr/bin/mysql -u $2 -p$3 -e 'select * from path_zambia_etl.facility_activity_report' | sed  's/\t/,/g' > $sourceFile
  /usr/bin/aws s3 sync $report_folder s3://opensrp/reports/etl --acl public-read --delete
  /usr/bin/curl -F username="PATH Zambia ETL" -F text="https://s3.amazonaws.com/opensrp/reports/$destinationFile" -F channel=$4 -F token="$5" https://slack.com/api/chat.postMessage
}

generateEtl $1 $2 $3 $4 $5 $6
