-- DELIMITER $$
-- DROP PROCEDURE IF EXISTS populate_etl_facility_activity_report$$
-- CREATE PROCEDURE populate_etl_facility_activity_report()

-- BEGIN
-- Initialise facility activity report table with birth registration and vaccination records

TRUNCATE TABLE path_zambia_etl.facility_activity_report;

USE openmrs;

INSERT INTO path_zambia_etl.facility_activity_report(
  encounter_id,
  zeir_id,
  patient_id,
  gender,
  birthdate,
  location_id,
  location_name,
  encounter_date,
  child_register_card_no,
  lt_12_months_male,
  lt_12_months_female,
  btwn_12_59_months_male,
  btwn_12_59_months_female,
  from_outside_catchment_area
)
select
r.encounter_id,
r.zeir_id,
r.patient_id,
r.gender,
r.birthdate,
r.location_id,
r.location_name,
r.encounter_date,
r.child_register_card_no,
r.lt_12_months_male,
r.lt_12_months_female,
r.btwn_12_59_months_male,
r.btwn_12_59_months_female,
r.from_outside_catchment_area
from
(select
  e.encounter_id,
  pi.identifier as zeir_id,
  e.patient_id,
  p.gender,
  p.birthdate,
  e.location_id,
  l.name as location_name,
  e.encounter_datetime as encounter_date,
  max(if (o.concept_id = '160636',o.value_boolean,null)) as from_outside_catchment_area,
  pa.value as child_register_card_no,
  if((gender = 'Male' or gender = 'M' or gender = '1') and TIMESTAMPDIFF(Month, birthdate, CURDATE()) < 12,1, null) as lt_12_months_male,
  if((gender = 'female' or gender = 'F' or gender = '2') and TIMESTAMPDIFF(Month, birthdate, CURDATE()) < 12,1, null) as lt_12_months_female,
  if((gender = 'Male' or gender = 'M' or gender = '1') and TIMESTAMPDIFF(Month, birthdate, CURDATE()) between 12 and 59,1, null) as btwn_12_59_months_male,
  if((gender = 'female' or gender = 'F' or gender = '2') and TIMESTAMPDIFF(Month, birthdate, CURDATE()) between 12 and 59,1, null) as btwn_12_59_months_female
 from encounter e
  inner join person p on p.person_id = e.patient_id
  inner join person_attribute pa on pa.person_id = e.patient_id
  inner join patient_identifier pi on e.patient_id = pi.patient_id
  inner join obs o on o.encounter_id = e.encounter_id
  inner join location l on e.location_id = l.location_id
 where e.encounter_type = 1
  and pi.identifier_type = 17
  and pa.person_attribute_type_id = 20
  and e.voided = 0
 group by e.encounter_id
 order by patient_id) r;

-- Birth Registration encounter type ID `1`
-- Vaccination encounter type ID: `4`
-- ZEIR ID: `17`
-- M_ZEIR ID: `18`
-- Child Register Card Number ID: `20`

-- Add vaccination records for patients that took place on different date
INSERT INTO path_zambia_etl.facility_activity_report(
  encounter_id,
  zeir_id,
  patient_id,
  gender,
  birthdate,
  location_id,
  location_name,
  encounter_date,
  child_register_card_no,
  lt_12_months_male,
  lt_12_months_female,
  btwn_12_59_months_male,
  btwn_12_59_months_female,
  from_outside_catchment_area
)
select
r.encounter_id,
r.zeir_id,
r.patient_id,
r.gender,
r.birthdate,
r.location_id,
r.location_name,
r.encounter_date,
r.child_register_card_no,
r.lt_12_months_male,
r.lt_12_months_female,
r.btwn_12_59_months_male,
r.btwn_12_59_months_female,
r.from_outside_catchment_area
from
(select
  e.encounter_id,
  pi.identifier as zeir_id,
  e.patient_id,
  p.gender,
  p.birthdate,
  e.location_id,
  l.name as location_name,
  e.encounter_datetime as encounter_date,
  max(if (o.concept_id = '160636',o.value_boolean,null)) as from_outside_catchment_area,
  pa.value as child_register_card_no,
  if((p.gender = 'Male' or p.gender = 'M' or p.gender = '1') and TIMESTAMPDIFF(Month, p.birthdate, CURDATE()) < 12,1, null) as lt_12_months_male,
  if((p.gender = 'female' or p.gender = 'F' or p.gender = '2') and TIMESTAMPDIFF(Month, p.birthdate, CURDATE()) < 12,1, null) as lt_12_months_female,
  if((p.gender = 'Male' or p.gender = 'M' or p.gender = '1') and TIMESTAMPDIFF(Month, p.birthdate, CURDATE()) between 12 and 59,1, null) as btwn_12_59_months_male,
  if((p.gender = 'female' or p.gender = 'F' or p.gender = '2') and TIMESTAMPDIFF(Month, p.birthdate, CURDATE()) between 12 and 59,1, null) as btwn_12_59_months_female
 from encounter e
  inner join person p on p.person_id = e.patient_id
  inner join person_attribute pa on pa.person_id = e.patient_id
  inner join patient_identifier pi on e.patient_id = pi.patient_id
  inner join obs o on o.encounter_id = e.encounter_id
  inner join location l on e.location_id = l.location_id
  right join path_zambia_etl.facility_activity_report far on e.patient_id = far.patient_id
 where e.encounter_type = 4
  and pi.identifier_type = 17
  and pa.person_attribute_type_id = 20
  and e.encounter_datetime != far.encounter_date
  and e.voided = 0
 group by e.patient_id
 order by patient_id) r;

 -- Insert unregistered growth monitoring encounters

 INSERT INTO path_zambia_etl.facility_activity_report(
   encounter_id,
   zeir_id,
   patient_id,
   gender,
   birthdate,
   location_id,
   location_name,
   encounter_date,
   child_register_card_no,
   lt_12_months_male,
   lt_12_months_female,
   btwn_12_59_months_male,
   btwn_12_59_months_female,
   from_outside_catchment_area
 )
 select
 r.encounter_id,
 r.zeir_id,
 r.patient_id,
 r.gender,
 r.birthdate,
 r.location_id,
 r.location_name,
 r.encounter_date,
 r.child_register_card_no,
 r.lt_12_months_male,
 r.lt_12_months_female,
 r.btwn_12_59_months_male,
 r.btwn_12_59_months_female,
 r.from_outside_catchment_area
 from
 (select
   e.encounter_id,
   pi.identifier as zeir_id,
   e.patient_id,
   p.gender,
   p.birthdate,
   e.location_id,
   l.name as location_name,
   e.encounter_datetime as encounter_date,
   max(if (o.concept_id = '160636',o.value_boolean,null)) as from_outside_catchment_area,
   pa.value as child_register_card_no,
   if((p.gender = 'Male' or p.gender = 'M' or p.gender = '1') and TIMESTAMPDIFF(Month, p.birthdate, CURDATE()) < 12,1, null) as lt_12_months_male,
   if((p.gender = 'female' or p.gender = 'F' or p.gender = '2') and TIMESTAMPDIFF(Month, p.birthdate, CURDATE()) < 12,1, null) as lt_12_months_female,
   if((p.gender = 'Male' or p.gender = 'M' or p.gender = '1') and TIMESTAMPDIFF(Month, p.birthdate, CURDATE()) between 12 and 59,1, null) as btwn_12_59_months_male,
   if((p.gender = 'female' or p.gender = 'F' or p.gender = '2') and TIMESTAMPDIFF(Month, p.birthdate, CURDATE()) between 12 and 59,1, null) as btwn_12_59_months_female
  from encounter e
   inner join person p on p.person_id = e.patient_id
   inner join person_attribute pa on pa.person_id = e.patient_id
   inner join patient_identifier pi on e.patient_id = pi.patient_id
   inner join location l on e.location_id = l.location_id
   inner join obs o on o.encounter_id = e.encounter_id
  where e.encounter_type = 2
   and pi.identifier_type = 17
   and pa.person_attribute_type_id = 20
   and e.encounter_datetime not in (select encounter_date from path_zambia_etl.facility_activity_report)
   and e.voided = 0
  group by e.encounter_id) r;

-- Update existing records with BCG vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if(concept_id = '886', 1, null) as bcg_dose_lt_1yr
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.bcg_dose_lt_1yr = vdb.bcg_dose_lt_1yr;

-- Update existing records with opv vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '783' and vaccination_sequence = '0', 1, null) as opv_dose_0
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '783' and vaccination_sequence = '0'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.opv_dose_0 = vdb.opv_dose_0;

-- Update existing records with opv 1 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '783' and vaccination_sequence = '1', 1, null) as opv_dose_1
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '783' and vaccination_sequence = '1'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.opv_dose_1 = vdb.opv_dose_1;

-- Update existing records with opv 2 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '783' and vaccination_sequence = '2', 1, null) as opv_dose_2
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '783' and vaccination_sequence = '2'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.opv_dose_2 = vdb.opv_dose_2;

-- Update existing records with opv 3 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '783' and vaccination_sequence = '3', 1, null) as opv_dose_3
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '783' and vaccination_sequence = '3'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.opv_dose_3 = vdb.opv_dose_3;

-- Update existing records with opv 4 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '783' and vaccination_sequence = '4', 1, null) as opv_dose_4
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '783' and vaccination_sequence = '4'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.opv_dose_4 = vdb.opv_dose_4;

-- Update existing records with pcv_dose_1 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '162342' and vaccination_sequence = '1', 1, null) as pcv_dose_1
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '162342' and vaccination_sequence = '1'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.pcv_dose_1 = vdb.pcv_dose_1;

-- Update existing records with pcv_dose_2 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '162342' and vaccination_sequence = '2', 1, null) as pcv_dose_2
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '162342' and vaccination_sequence = '2'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.pcv_dose_2 = vdb.pcv_dose_2;

-- Update existing records with pcv_dose_3 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '162342' and vaccination_sequence = '3', 1, null) as pcv_dose_3
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '162342' and vaccination_sequence = '3'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.pcv_dose_3 = vdb.pcv_dose_3;

-- Update existing records with pentavalent_dose_1 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '1685' and vaccination_sequence = '1', 1, null) as pentavalent_dose_1
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '1685' and vaccination_sequence = '1'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.pentavalent_dose_1 = vdb.pentavalent_dose_1;


-- Update existing records with pentavalent_dose_2 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '1685' and vaccination_sequence = '2', 1, null) as pentavalent_dose_2
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '1685' and vaccination_sequence = '2'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.pentavalent_dose_2 = vdb.pentavalent_dose_2;

-- Update existing records with pentavalent_dose_3 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '1685' and vaccination_sequence = '3', 1, null) as pentavalent_dose_3
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '1685' and vaccination_sequence = '3'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.pentavalent_dose_3 = vdb.pentavalent_dose_3;

-- Update existing records with rv_dose_1 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '159698' and vaccination_sequence = '1', 1, null) as rv_dose_1
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '159698' and vaccination_sequence = '1'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.rv_dose_1 = vdb.rv_dose_1;

-- Update existing records with rv_dose_2 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '159698' and vaccination_sequence = '2', 1, null) as rv_dose_2
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '159698' and vaccination_sequence = '2'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.rv_dose_2 = vdb.rv_dose_2;

-- Update existing records with measles_mr_dose_1 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '36' and vaccination_sequence = '1', 1, null) as measles_mr_dose_1
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '36' and vaccination_sequence = '1'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.measles_mr_dose_1 = vdb.measles_mr_dose_1;

-- Update existing records with measles_mr_dose_2 vaccination data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select person_id, vaccination_date, encounter_id,
  if (concept_id = '36' and vaccination_sequence = '2', 1, null) as measles_mr_dose_2
from (select
  parent.person_id,
  parent.concept_id,
  parent.encounter_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 4 and e.voided = 0) as t
  where t.vaccination_date is not null and concept_id = '36' and vaccination_sequence = '2'
  group by encounter_id
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.measles_mr_dose_2 = vdb.measles_mr_dose_2;

-- Update existing records with growth monitoring data

UPDATE path_zambia_etl.facility_activity_report far
join (
  select
    e.encounter_id,
    e.encounter_datetime,
    e.patient_id,
    if((o.value_numeric is not null) and TIMESTAMPDIFF(Month, birthdate, CURDATE()) < 23,1, null) as 0_23_months_weighed,
    if((o.value_numeric is not null) and TIMESTAMPDIFF(Month, birthdate, CURDATE()) between 23 and 59,1, null) as 24_59_months_weighed
    from encounter e
    inner join obs o on o.encounter_id = e.encounter_id
    inner join person p on p.person_id = e.patient_id
    where e.voided = 0 and o.concept_id = 5089) gmf on
    gmf.patient_id = far.patient_id and gmf.encounter_datetime = far.encounter_date
set
  far.0_23_months_weighed = gmf.0_23_months_weighed,
  far.24_59_months_weighed = gmf.24_59_months_weighed;

-- Update all encounters with their growth
UPDATE path_zambia_etl.facility_activity_report far
join (
  select
	patient_id,
  encounter_id,
  encounter_datetime,
	if((TIMESTAMPDIFF(Month, birthdate, CURDATE()) < 23) and (weight - previous_weight) <= 0,1, null) as 0_23_months_no_weight_gain,
	if((TIMESTAMPDIFF(Month, birthdate, CURDATE()) between 23 and 59) and (weight - previous_weight) <= 0,1, null) as 24_59_months_no_weight_gain
from
(select
	e.patient_id,
  e.encounter_id,
  e.encounter_datetime,
  o.value_numeric as weight,
  p.birthdate,
  (select value_numeric from obs where
	 concept_id = '5089' and obs_datetime < e.encounter_datetime and person_id = e.patient_id order by encounter_id desc limit 1) as previous_weight
  from encounter e
  inner join obs o on o.encounter_id = e.encounter_id
  inner join person p on p.person_id = e.patient_id
  where e.encounter_type = 2 and o.concept_id = '5089'
  group by e.encounter_datetime) weight_gains) wg on
    wg.patient_id = far.patient_id and wg.encounter_datetime = far.encounter_date
set
  far.0_23_months_no_weight_gain = wg.0_23_months_no_weight_gain,
  far.24_59_months_no_weight_gain = wg.24_59_months_no_weight_gain;

-- Add providers
UPDATE path_zambia_etl.facility_activity_report far
join(
  select encounter_id, ep.provider_id, name from encounter_provider ep inner join provider p on ep.provider_id = p.provider_id
) p on p.encounter_id = far.encounter_id
set
  far.provider_id = p.provider_id,
  far.provider_name = p.name;

-- END$$
-- DELIMITER ;

-- CALL populate_etl_facility_activity_report();
