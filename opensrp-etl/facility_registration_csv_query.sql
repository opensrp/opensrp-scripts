SELECT
  zeir_id                   AS "ZEIR ID",
  gender                    AS "Gender",
  DOB                       AS "DOB",
  date_first_seen           AS "Date first seen",
  TIMESTAMP_OF_REGISTRATION AS "Timestamp of registration",
  facility_id               AS "Facility of registration ID",
  facility_name             AS "Facility of registration name",
  CASE WHEN district SIMILAR TO 'so %|we %'
    THEN substring(district FROM 4)
  ELSE district
  END                       AS "District",
  CASE WHEN province SIMILAR TO 'so %|we %'
    THEN substring(province FROM 4)
  ELSE province
  END                       AS "Province",
  provider_id               AS "Provider ID",
  provider_name             AS "Provider name",
  place_of_birth            AS "Place of birth",
  health_facility           AS "Facility of Birth",
  residential_area          AS "Residential area"
FROM facility_registration_report
ORDER BY timestamp_of_registration DESC;


