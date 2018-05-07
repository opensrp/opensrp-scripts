SELECT
  zeir_id                   AS "ZEIR ID",
  gender                    AS "Gender",
  date_of_birth             AS "DOB",
  date_first_seen           AS "Date first seen",
  TIMESTAMP_OF_REGISTRATION AS "Timestamp of registration",
  facility_id               AS "Facility of registration ID",
  facility_name             AS "Facility of registration name",
  district                  AS "District",
  province                  AS "Province",
  provider_id               AS "Provider ID",
  provider_name             AS "Provider name",
  place_of_birth            AS "Place of birth",
  facility_of_birth         AS "Facility of Birth",
  residential_area          AS "Residential area"
FROM birth_registration
ORDER BY timestamp_of_registration DESC