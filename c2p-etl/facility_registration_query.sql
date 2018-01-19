﻿SELECT
   zeir_id as "ZEIR ID",
   gender as "Gender",
   dob::timestamp::date as "DOB",
   date_first_seen as "Date first seen",
   timestamp_of_registration::TIMESTAMP(0) as "Timestamp of registration",
   facility_id as "Facility of registration ID",

CASE WHEN facility_name SIMILAR TO 'so %|we %'
THEN substring(facility_name from 4)
ELSE facility_name
END as "Facility of registration name",

CASE WHEN district SIMILAR TO 'so %|we %'
THEN substring(district from 4)
ELSE district
END as "District",

CASE WHEN province SIMILAR TO 'so %|we %'
THEN substring(province from 4)
ELSE province
END as "Province",
provider_id as "Provider ID",
provider_name as "Provider name",
place_of_birth as "Place of birth",
health_facility as "Facility of Birth",
residential_area as "Residential area"
FROM facility_registration_report;
