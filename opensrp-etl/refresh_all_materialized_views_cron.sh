#!/bin/bash

#Refresh all public materialized views
export PGPASSWORD="postgres_user_password"
psql -h localhost -d opensrp -U postgres -f ./refresh_all_materialized_views.sql
unset PGPASSWORD
