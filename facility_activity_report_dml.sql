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
  child_register_card_no
)
select
r.zeir_id,
r.patient_id,
r.gender,
r.location_name,
r.activity_date,
r.child_register_card_no
from
(select
  pi.identifier as zeir_id,
  e.patient_id,
  p.gender,
  max(if (o.concept_id = '163531',o.value_text,null)) as location_name,
  max(if (o.concept_id = '163138',o.value_datetime,null)) as activity_date,
  pa.value as child_register_card_no
 from encounter e join encounter_type et on e.encounter_type = et.encounter_type_id
 inner join person p on p.person_id = e.patient_id
 inner join person_attribute pa on pa.person_id = e.patient_id
 inner join patient_identifier pi on e.patient_id = pi.patient_id
 inner join obs o on o.encounter_id = e.encounter_id
 where e.encounter_type = 29 and pi.identifier_type = 17 and pa.person_attribute_type_id = 20
 group by pi.identifier) r;

 -- Populate the encounter date data
 -- Populate the location data
 -- Polulate child card number data

END$$
DELIMITER;
