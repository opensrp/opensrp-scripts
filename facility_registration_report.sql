
-- Truncate the registration flat table for new extract
TRUNCATE TABLE path_zambia_etl.facility_registration_report;

 -- Initialise facility registration report table with birth registration info
INSERT INTO path_zambia_etl.facility_registration_report(
person_id,
zeir_id,
gender,
dob
)
SELECT
person_id,
patient_identifier.identifier,
gender,
birthdate

FROM openmrs.person
JOIN  openmrs.patient_identifier on person_id =  patient_identifier.patient_id and patient_identifier.identifier_type =17;

-- Update observation data
UPDATE path_zambia_etl.facility_registration_report pr,
(   SELECT value_datetime, person_id, encounter_id, location_id, date_created
    FROM openmrs.obs where concept_id=163260
) ob
SET pr.date_first_seen  = ob.value_datetime, pr.timestamp_of_registration = ob.date_created, pr.facility_id = ob.location_id,
pr.provider_id = (SELECT provider_id FROM openmrs.encounter_provider WHERE encounter_id = ob.encounter_id limit 1)
WHERE pr.person_id = ob.person_id;

-- Update missing locations
UPDATE
    path_zambia_etl.facility_registration_report
    INNER JOIN openmrs.encounter
      ON path_zambia_etl.facility_registration_report.person_id = patient_id AND openmrs.encounter.location_id IS NOT NULL AND
         path_zambia_etl.facility_registration_report.facility_id IS NULL
SET path_zambia_etl.facility_registration_report.facility_id = openmrs.encounter.location_id;

-- Update provider name
  UPDATE path_zambia_etl.facility_registration_report prns,
(   SELECT provider_id, person_id
    FROM path_zambia_etl.facility_registration_report
) pns
SET
prns.provider_name =  (SELECT name FROM openmrs.provider WHERE provider_id = pns.provider_id)
WHERE prns.person_id = pns.person_id;

-- Delete records  Demo records
DELETE FROM path_zambia_etl.facility_registration_report WHERE provider_id =1;

-- Update patient names
  UPDATE path_zambia_etl.facility_registration_report pn,
(   SELECT given_name, family_name, person_id
    FROM openmrs.person_name
) ptn
SET pn.first_name  = ptn.given_name,
pn.last_name = ptn.family_name,
pn.residential_area = (SELECT address3 FROM openmrs.person_address WHERE person_id =  ptn.person_id order by person_address_id desc limit 1)
WHERE pn.person_id = ptn.person_id;

-- Update location data
UPDATE path_zambia_etl.facility_registration_report prl,
(   SELECT location_id, name
    FROM openmrs.location
) loc
SET prl.facility_name  = (if(loc.name like 'so %',SUBSTR(loc.name,4), loc.name))
WHERE prl.facility_id = loc.location_id;

  -- Update birth location
  UPDATE path_zambia_etl.facility_registration_report prb,
(   SELECT value_coded, person_id
    FROM openmrs.obs WHERE concept_id = 1572
) pob
SET prb.place_of_birth  = (SELECT name FROM openmrs.concept_name WHERE concept_id = pob.value_coded AND locale = 'en')
WHERE prb.person_id = pob.person_id;

 -- Update 'HIV exposure
  UPDATE path_zambia_etl.facility_registration_report cn,
(   SELECT value_coded, person_id
    FROM openmrs.obs WHERE concept_id = 1396
) cnt
SET cn.hiv_exposure  = (SELECT name FROM openmrs.concept_name WHERE concept_id = cnt.value_coded AND locale = 'en' AND concept_name_type='FULLY_SPECIFIED')
WHERE cn.person_id = cnt.person_id;

 -- Update facility location uuid with names
UPDATE
path_zambia_etl.facility_registration_report
 INNER JOIN openmrs.location ON path_zambia_etl.facility_registration_report.health_facility  = openmrs.location.uuid
SET path_zambia_etl.facility_registration_report.health_facility = SUBSTR(openmrs.location.name,4);

 -- Update Other residential area
  UPDATE path_zambia_etl.facility_registration_report otl,
(   SELECT residential_area, person_id
    FROM path_zambia_etl.facility_registration_report WHERE residential_area = 'Other'
) aorl
SET otl.residential_area  = (SELECT address5 FROM openmrs.person_address WHERE person_id = aorl.person_id)
WHERE otl.person_id = aorl.person_id;

 -- Update Other health facility
  UPDATE path_zambia_etl.facility_registration_report ohf,
(   SELECT person_id
    FROM path_zambia_etl.facility_registration_report WHERE health_facility = 'Other'
) aohf
SET ohf.health_facility   = (SELECT value_text FROM openmrs.obs WHERE concept_id = 160632 AND person_id = aohf.person_id order by obs_id desc limit 1)
WHERE ohf.person_id = aohf.person_id;


 -- Update mulformed dates
  UPDATE path_zambia_etl.facility_registration_report mfd,
(   SELECT person_id
    FROM path_zambia_etl.facility_registration_report WHERE date_first_seen like '00%'
) bds
SET mfd.date_first_seen  = NULL
WHERE mfd.person_id = bds.person_id;

 -- Update facility location for health centres
UPDATE
path_zambia_etl.facility_registration_report
 INNER JOIN openmrs.location_tag_map ON path_zambia_etl.facility_registration_report .facility_id = openmrs.location_tag_map.location_id  AND openmrs.location_tag_map.location_tag_id = 4
SET path_zambia_etl.facility_registration_report.district =  (SELECT (if(name like 'so %',SUBSTR(name,4), name)) FROM openmrs.location WHERE location_id = (SELECT parent_location FROM openmrs.location WHERE location_id=( path_zambia_etl.facility_registration_report.facility_id))),
path_zambia_etl.facility_registration_report.province = (SELECT (if(name like 'so %',SUBSTR(name,4), name)) FROM openmrs.location WHERE location_id = (SELECT parent_location FROM openmrs.location WHERE location_id=( (SELECT parent_location FROM openmrs.location WHERE location_id=( path_zambia_etl.facility_registration_report.facility_id)) )));

-- Update facility location for zones
UPDATE
path_zambia_etl.facility_registration_report
 INNER JOIN openmrs.location_tag_map ON path_zambia_etl.facility_registration_report .facility_id = openmrs.location_tag_map.location_id  AND openmrs.location_tag_map.location_tag_id = 5
SET path_zambia_etl.facility_registration_report.district = (SELECT (if(name like 'so %',SUBSTR(name,4), name)) FROM openmrs.location WHERE location_id =
(SELECT parent_location FROM openmrs.location WHERE location_id=
(SELECT parent_location FROM openmrs.location WHERE location_id=( path_zambia_etl.facility_registration_report.facility_id)))),

path_zambia_etl.facility_registration_report.province = (SELECT (if(name like 'so %',SUBSTR(name,4), name)) FROM openmrs.location WHERE location_id = (SELECT parent_location FROM openmrs.location WHERE location_id = (SELECT parent_location FROM openmrs.location WHERE location_id=
(SELECT parent_location FROM openmrs.location WHERE location_id=( path_zambia_etl.facility_registration_report.facility_id)))));

