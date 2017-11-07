SELECT
zeir_id as 'ZEIR ID',
gender as 'Gender',
dob as 'DOB',
date_first_seen as 'Date first seen',
timestamp_of_registration as 'Timestamp of registration',
facility_id as 'Facility of registration ID',
facility_name as 'Facility of registration name',
district as 'District',
province as 'Province',
provider_id as 'Provider ID',
provider_name as 'Provider name',
place_of_birth as 'Place of birth',
health_facility as 'Facility of Birth',
residential_area as 'Residential area'
FROM path_zambia_etl.facility_registration_report;
