SET @@group_concat_max_len = 1000000;
SELECT DISTINCT uuids FROM (
SELECT  group_concat(e.encounter_id) AS uuids
FROM encounter e
  JOIN obs o USING (encounter_id)
WHERE e.encounter_type = 2
GROUP BY patient_id, e.location_id, encounter_datetime, concept_id) a;
SET @@group_concat_max_len = 1024;