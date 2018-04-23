
SELECT count(*) FROM openmrs.encounter WHERE encounter_type =2 AND voided = 0;

SELECT count(*) FROM encounter INNER JOIN event_uuids USING (uuid) WHERE encounter_type =2 AND voided =0;


SELECT count(DISTINCT uuids) FROM (
SELECT  group_concat(e.encounter_id) AS uuids, count(*) as count
FROM openmrs.encounter e
  JOIN openmrs.obs o USING (encounter_id)
WHERE e.encounter_type = 2 AND e.voided = 0
GROUP BY patient_id, e.location_id, encounter_datetime, concept_id
HAVING count>1) a;