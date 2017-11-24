-- Truncate the encounter flat table for new extract
TRUNCATE TABLE path_zambia_etl.facility_encounter_report;

-- Initialise facility registration report table with birth registration info
INSERT INTO path_zambia_etl.facility_encounter_report(
encounter_id,
encounter_date,
person_id,
fac_id,
gender,
dob
)
SELECT
encounter_id,
encounter_datetime,
patient_id,
location_id,
openmrs.person.gender,
openmrs.person.birthdate

FROM openmrs.encounter
INNER JOIN openmrs.person  on person_id = openmrs.encounter.patient_id AND openmrs.encounter.encounter_type NOT IN(1,8);

-- provider id
UPDATE
    path_zambia_etl.facility_encounter_report
    INNER JOIN openmrs.encounter_provider  ON path_zambia_etl.facility_encounter_report.encounter_id = openmrs.encounter_provider.encounter_id
SET path_zambia_etl.facility_encounter_report.provider_id = openmrs.encounter_provider.provider_id;

-- Clean up Demo records
DELETE FROM path_zambia_etl.facility_encounter_report WHERE provider_id =1;

-- provider name
UPDATE
    path_zambia_etl.facility_encounter_report
    INNER JOIN openmrs.provider  ON path_zambia_etl.facility_encounter_report.provider_id = openmrs.provider.provider_id
SET path_zambia_etl.facility_encounter_report.provider_name = openmrs.provider.name;

-- Update ZEIR ID child
UPDATE
    path_zambia_etl.facility_encounter_report
    INNER JOIN openmrs.patient_identifier  ON path_zambia_etl.facility_encounter_report.person_id = patient_id  AND identifier_type =17
SET facility_encounter_report.zeir_id = openmrs.patient_identifier.identifier;

-- Update ZEIR ID mother
UPDATE
    path_zambia_etl.facility_encounter_report
    INNER JOIN openmrs.patient_identifier  ON openmrs.patient_identifier.identifier = concat(zeir_id,"_mother")
SET facility_encounter_report.mother_id = openmrs.patient_identifier.identifier;

-- Update location name
UPDATE
    path_zambia_etl.facility_encounter_report
    INNER JOIN openmrs.location  ON path_zambia_etl.facility_encounter_report.fac_id = openmrs.location.location_id
SET path_zambia_etl.facility_encounter_report.fac_name = (if(openmrs.location.name like 'so %',SUBSTR(openmrs.location.name,4), openmrs.location.name));

-- Update facility location for health centres
UPDATE
path_zambia_etl.facility_encounter_report
 INNER JOIN openmrs.location_tag_map ON path_zambia_etl.facility_encounter_report.fac_id = openmrs.location_tag_map.location_id  AND openmrs.location_tag_map.location_tag_id = 4
SET path_zambia_etl.facility_encounter_report.district_id = (SELECT location_id FROM openmrs.location WHERE location_id = (SELECT parent_location FROM openmrs.location WHERE location_id=( path_zambia_etl.facility_encounter_report.fac_id)));

-- Update facility location for zones
UPDATE
path_zambia_etl.facility_encounter_report
 INNER JOIN openmrs.location_tag_map ON path_zambia_etl.facility_encounter_report .fac_id = openmrs.location_tag_map.location_id  AND openmrs.location_tag_map.location_tag_id = 5
SET path_zambia_etl.facility_encounter_report.district_id = (SELECT location_id FROM openmrs.location WHERE location_id =
(SELECT parent_location FROM openmrs.location WHERE location_id=
(SELECT parent_location FROM openmrs.location WHERE location_id=( path_zambia_etl.facility_encounter_report.fac_id))));

 -- Update Province id
  UPDATE path_zambia_etl.facility_encounter_report prov,
(   SELECT distinct district_id
    FROM path_zambia_etl.facility_encounter_report
) aprov
SET prov.province_id  = (SELECT location_id FROM openmrs.location WHERE location_id = (SELECT parent_location FROM openmrs.location WHERE location_id=((SELECT location_id FROM openmrs.location WHERE location_id = aprov.district_id ))))
WHERE prov.district_id = aprov.district_id;

-- Update district name
UPDATE
    path_zambia_etl.facility_encounter_report
    INNER JOIN openmrs.location  ON path_zambia_etl.facility_encounter_report.district_id = openmrs.location.location_id
SET path_zambia_etl.facility_encounter_report.district_name = (if(openmrs.location.name like 'so %',SUBSTR(openmrs.location.name,4), openmrs.location.name));

-- Update province name
UPDATE
    path_zambia_etl.facility_encounter_report
    INNER JOIN openmrs.location  ON path_zambia_etl.facility_encounter_report.province_id = openmrs.location.location_id
SET path_zambia_etl.facility_encounter_report.province_name = (if(openmrs.location.name like 'so %',SUBSTR(openmrs.location.name,4), openmrs.location.name));

-- Update columns
UPDATE path_zambia_etl.facility_encounter_report cwi
SET
-- Update Weight
child_weight  = (SELECT value_numeric FROM openmrs.obs WHERE encounter_id = cwi.encounter_id AND concept_id =5089),
z_score  = (SELECT value_numeric FROM openmrs.obs WHERE encounter_id = cwi.encounter_id AND concept_id =162584),

-- Update Vaccines
BCG1 = (SELECT if(value_numeric =1,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 886  AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

OPV0  = (SELECT if(value_numeric =0,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id =783 AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

OPV1  = (SELECT if(value_numeric =1,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id =783 AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

PCV1  = (SELECT if(value_numeric =1,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id =162342 AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

Penta1  = (SELECT if(value_numeric =1,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 1685 AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

Rota1  = (SELECT if(value_numeric =1,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 159698 AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

OPV2  = (SELECT if(value_numeric =2,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 783 AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

PCV2  = (SELECT if(value_numeric =2,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 162342 AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

Penta2  = (SELECT if(value_numeric =2,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 1685 AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

Rota2  = (SELECT if(value_numeric =2,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 159698 AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

OPV3  = (SELECT if(value_numeric =3,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 783 AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

PCV3  = (SELECT if(value_numeric =3,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 162342 AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

Penta3  = (SELECT if(value_numeric =3,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 1685  AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

Measles1  = (SELECT if(value_numeric =1,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 36  AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

MR1  = (SELECT if(value_numeric =1,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 162586  AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

OPV4  = (SELECT if(value_numeric =4,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 783 AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

Measles2  = (SELECT if(value_numeric =2,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 36  AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

MR2  = (SELECT if(value_numeric =2,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 162586  AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

BCG2 = (SELECT if(value_numeric =2,1,NULL)  FROM openmrs.obs WHERE obs_group_id in (
SELECT obs_id  FROM openmrs.obs WHERE concept_id = 886  AND encounter_id  =cwi.encounter_id) AND concept_id =1418),

vitamin_a = (SELECT if(value_coded =1065,1,NULL)  FROM openmrs.obs WHERE concept_id = 161534  AND encounter_id = cwi.encounter_id),
mebendezol = (SELECT if(value_coded =1065,1,NULL)  FROM openmrs.obs WHERE concept_id = 159922  AND encounter_id = cwi.encounter_id)

WHERE encounter_id = cwi.encounter_id;

-- Update child weighed
UPDATE path_zambia_etl.facility_encounter_report SET child_weighed = 1 WHERE child_weight IS NOT NULL;

-- Clean up unused encounter rows
DELETE FROM path_zambia_etl.facility_encounter_report WHERE child_weight is NULL AND child_weighed AND z_score is NULL AND BCG1 is NULL AND OPV0 is NULL AND OPV1 is NULL AND PCV1 is NULL AND Penta1 is NULL AND Rota1 is NULL AND OPV2 is NULL AND PCV2 is NULL AND Penta2 is NULL AND Rota2 is NULL AND OPV3 is NULL AND PCV3 is NULL AND Penta3 is NULL AND Measles1 is NULL AND MR1 is NULL AND OPV4 is NULL AND Measles2 is NULL AND MR2 is NULL AND BCG2 is NULL AND vitamin_a is NULL AND mebendezol is NULL;

