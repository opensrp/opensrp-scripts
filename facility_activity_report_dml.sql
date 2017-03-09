DELIMITER $$
DROP PROCEDURE IF EXISTS populate_etl_facility_activity_report$$
CREATE PROCEDURE populate_etl_facility_activity_report()

BEGIN
-- Initialise facility activity report table

INSERT INTO facility_activity_report(
  encounter_id,
  zeir_id,
  patient_id,
  gender,
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
  max(if (o.concept_id = '163531',o.value_text,null)) as location_name,
  max(if (o.concept_id = '163138',o.obs_datetime,null)) as encounter_date,
  max(if (o.concept_id = '160636',o.value_boolean,null)) as from_outside_catchment_area,
  pa.value as child_register_card_no,
  if((gender = 'Male' or gender = 'M' or gender = '1') and TIMESTAMPDIFF(Month, birthdate, CURDATE()) < 12,1, null) as lt_12_months_male,
  if((gender = 'female' or gender = 'F' or gender = '2') and TIMESTAMPDIFF(Month, birthdate, CURDATE()) < 12,1, null) as lt_12_months_female,
  if((gender = 'Male' or gender = 'M' or gender = '1') and TIMESTAMPDIFF(Month, birthdate, CURDATE()) between 12 and 59,1, null) as btwn_12_59_months_male,
if((gender = 'female' or gender = 'F' or gender = '2') and TIMESTAMPDIFF(Month, birthdate, CURDATE()) between 12 and 59,1, null) as btwn_12_59_months_female
 from encounter e
  join encounter_type et on e.encounter_type = et.encounter_type_id
  inner join person p on p.person_id = e.patient_id
  inner join person_attribute pa on pa.person_id = e.patient_id
  inner join patient_identifier pi on e.patient_id = pi.patient_id
  inner join obs o on o.encounter_id = e.encounter_id
 where e.encounter_type = 29
  and pi.identifier_type = 17
  and pa.person_attribute_type_id = 20
  and e.voided = 0
 group by e.encounter_id) r;

-- Update existing birth registrations with data for vaccinations
UPDATE facility_activity_report far
join (
  select person_id, vaccination_date,
  if(concept_id = '886', 1, null) as bcg_dose_lt_1yr,
  if (concept_id = '783' and vaccination_sequence = '0', 1, null) as opv_dose_0,
  if (concept_id = '783' and vaccination_sequence = '1', 1, null) as opv_dose_1,
  if (concept_id = '783' and vaccination_sequence = '2', 1, null) as opv_dose_2,
  if (concept_id = '783' and vaccination_sequence = '3', 1, null) as opv_dose_3,
  if (concept_id = '783' and vaccination_sequence = '4', 1, null) as opv_dose_4,
  if (concept_id = '162342' and vaccination_sequence = '1', 1, null) as pcv_dose_1,
  if (concept_id = '162342' and vaccination_sequence = '2', 1, null) as pcv_dose_2,
  if (concept_id = '162342' and vaccination_sequence = '3', 1, null) as pcv_dose_3,
  if (concept_id = '1685' and vaccination_sequence = '1', 1, null) as pentavalent_dose_1,
  if (concept_id = '1685' and vaccination_sequence = '2', 1, null) as pentavalent_dose_2,
  if (concept_id = '1685' and vaccination_sequence = '3', 1, null) as pentavalent_dose_3,
  if (concept_id = '159698' and vaccination_sequence = '1', 1, null) as rv_dose_1,
  if (concept_id = '159698' and vaccination_sequence = '2', 1, null) as rv_dose_2,
  if (concept_id = '36' and vaccination_sequence = '1', 1, null) as measles_mr_dose_1,
  if (concept_id = '36' and vaccination_sequence = '2', 1, null) as measles_mr_dose_2
from (select
  parent.person_id,
  parent.obs_id,
  parent.concept_id,
  (select value_datetime from obs where concept_id = 1410 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_date,
  (select value_numeric from obs where concept_id = 1418 and obs_group_id = parent.obs_id and person_id = parent.person_id) as vaccination_sequence
  from obs as parent
  join encounter e on e.encounter_id = parent.encounter_id
  where e.encounter_type = 31 and e.voided = 0) as t
  where t.vaccination_date is not null;
) vdb on
vdb.person_id = far.patient_id and vdb.vaccination_date = far.encounter_date
set
  far.bcg_dose_lt_1yr = vdb.bcg_dose_lt_1yr,
  far.opv_dose_0 = vbd.opv_dose_0,
  far.opv_dose_1 = vbd.opv_dose_1,
  far.opv_dose_2 = vbd.opv_dose_2,
  far.opv_dose_3 = vbd.opv_dose_3,
  far.opv_dose_4 = vbd.opv_dose_4,
  far.pentavalent_dose_1 = vbd.pentavalent_dose_1,
  far.pentavalent_dose_2 = vbd.pentavalent_dose_2,
  far.pentavalent_dose_3 = vbd.pentavalent_dose_3,
  far.pcv_dose_1 = vbd.pcv_dose_1,
  far.pcv_dose_2 = vbd.pcv_dose_2,
  far.pcv_dose_3 = vbd.pcv_dose_3,
  far.rv_dose_1 = vbd.rv_dose_1,
  far.rv_dose_2 = vbd.rv_dose_2,
  far.measles_mr_dose_1 = vbd.measles_mr_dose_1,
  far.measles_mr_dose_2 = vbd.measles_mr_dose_2;

-- Add vaccination encounters that have not been captured in existing data


END$$
DELIMITER;
