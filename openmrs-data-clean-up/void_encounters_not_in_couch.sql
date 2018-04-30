-- Remove all encounters not on couch
SET @@group_concat_max_len = 1000000;
-- index search fields
CREATE INDEX idx_uuid on encounter(uuid);
CREATE INDEX idx_encounter_search on encounter(encounter_type,voided, uuid) ;

SELECT uuid
FROM openmrs.encounter e
WHERE e.encounter_type = 2 AND e.voided = 0 AND e.uuid NOT IN (SELECT u.uuid  FROM openmrs.event_uuids u);
SET @@group_concat_max_len = 1024;

-- drop indexing

CREATE INDEX idx_uuid on encounter(uuid);
CREATE INDEX idx_encounter_search on encounter(encounter_type,voided, uuid) ;