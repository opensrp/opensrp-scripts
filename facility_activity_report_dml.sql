DELIMITER $$
DROP PROCEDURE IF EXISTS populate_etl_facility_activity_report$$
CREATE PROCEDURE populate_etl_facility_activity_report()

BEGIN
-- Initialise facility activity report table

INSERT INTO facility_activity_report(
  zeir_id,
  patient_id,
  gender,
  location_name,
  activity_date,
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
r.activity_date,
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
  max(if (o.concept_id = '163138',o.value_datetime,null)) as activity_date,
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
 group by pi.identifier) r;

END$$
DELIMITER;
