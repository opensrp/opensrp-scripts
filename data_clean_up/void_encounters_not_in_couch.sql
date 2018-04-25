-- Remove all encounters not on couch
SET @@group_concat_max_len = 1000000;
SELECT uuid
FROM openmrs.encounter e
WHERE e.encounter_type = 2 AND e.voided = 0 AND e.uuid NOT IN (SELECT u.uuid  FROM openmrs.event_uuids u);
SET @@group_concat_max_len = 1024;