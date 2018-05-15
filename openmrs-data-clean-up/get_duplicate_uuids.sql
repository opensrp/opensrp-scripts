SET @@group_concat_max_len = 1000000;
-- First remove all encounters not on couch
-- index fields to search
CREATE INDEX idx_encounter_id on encounter(encounter_id);
CREATE INDEX idx_obs_encounter_id on obs(encounter_id);
CREATE INDEX idx_concept_id on obs(concept_id);
CREATE INDEX idx_encounter_type on encounter(encounter_type);
CREATE INDEX idx_voided on encounter(voided);
CREATE INDEX idx_ecounter_g on encounter(patient_id, location_id, encounter_datetime, concept_id);
SELECT DISTINCT uuids FROM (
SELECT  group_concat(e.encounter_id) AS uuids, count(*) as count
FROM openmrs.encounter e
  JOIN openmrs.obs o USING (encounter_id)
WHERE e.encounter_type = 2 AND e.voided = 0
GROUP BY patient_id, e.location_id, encounter_datetime, concept_id
HAVING count>1) a;

-- drop indexing
ALTER TABLE encounter DROP idx_encounter_id;
ALTER TABLE obs DROP idx_obs_encounter_id;
ALTER TABLE obs idx_concept_id ;
ALTER TABLE encounter idx_encounter_type;
ALTER TABLE encounter idx_voided;
ALTER TABLE idx_ecounter_g;

SET @@group_concat_max_len = 1024;