CREATE INDEX idx_relationship_id on relationship(relationship_id);
CREATE INDEX idx_zeir_id on zeir_relations(zeir_id);
CREATE INDEX idx_mother on zeir_relations(mother_base_id);

select relationship_id
  from relationship r
    join patient_identifier c1 on c1.patient_id = person_a and c1.identifier_type = 17
    join patient_identifier c2 on c2.patient_id = person_b and c2.identifier_type = 17
    join zeir_relations r1 on c1.identifier = r1.zeir_id
    join zeir_relations r2 on c2.identifier = r2.zeir_id
  where relationship = 2 and r1.mother_base_id != r2.mother_base_id;

ALTER TABLE relationship DROP INDEX idx_relationship_id;
ALTER TABLE zeir_relations DROP INDEX idx_zeir_id;
ALTER TABLE zeir_relations DROP INDEX idx_mother;

