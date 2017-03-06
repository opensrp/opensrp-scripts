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
  lt_12_months_female
)
select
r.encounter_id,
r.zeir_id,
r.patient_id,
r.gender,
r.location_name,
r.activity_date,
r.child_register_card_no,
r.lt_12_months_male,
r.lt_12_months_female
from
(select
  e.encounter_id,
  pi.identifier as zeir_id,
  e.patient_id,
  p.gender,
  max(if (o.concept_id = '163531',o.value_text,null)) as location_name,
  max(if (o.concept_id = '163138',o.value_datetime,null)) as activity_date,
  pa.value as child_register_card_no,
  if(p.gender = 'Male',1, if(p.gender = 'MALE', 1, if(p.gender = 'M', 1, if(p.gender = '1', 1, null)))) as lt_12_months_male,
  if(p.gender = 'female',1, if(p.gender = 'FEMALE', 1, if(p.gender = 'F', 1, if(p.gender = '2', 1, null)))) as lt_12_months_female
 from encounter e
  join encounter_type et on e.encounter_type = et.encounter_type_id
  inner join person p on p.person_id = e.patient_id
  inner join person_attribute pa on pa.person_id = e.patient_id
  inner join patient_identifier pi on e.patient_id = pi.patient_id
  inner join obs o on o.encounter_id = e.encounter_id
 where e.encounter_type = 29
  and pi.identifier_type = 17
  and pa.person_attribute_type_id = 20
  and TIMESTAMPDIFF(Month, p.birthdate, CURDATE()) < 12
 group by pi.identifier) r;

-- Populate lt_12_months indicators

END$$
DELIMITER;
