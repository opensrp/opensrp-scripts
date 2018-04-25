SET @@group_concat_max_len = 1000000;
-- First remove all encounters not on couch
SELECT DISTINCT uuids FROM (
SELECT  group_concat(e.encounter_id) AS uuids, count(*) as count
FROM openmrs.encounter e
  JOIN openmrs.obs o USING (encounter_id)
WHERE e.encounter_type = 2 AND e.voided = 0
GROUP BY patient_id, e.location_id, encounter_datetime, concept_id
HAVING count>1) a;
SET @@group_concat_max_len = 1024;