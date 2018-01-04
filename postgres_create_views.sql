#creating views to hold data extracted from json docs from couchDB

CREATE MATERIALIZED VIEW event AS
SELECT
  doc->>'baseEntityId' as base_entity_id,
  doc->>'eventDate' as event_date,
  doc->>'eventType' as event_type,
  doc->>'providerId' as provider_id,
  doc->>'locationId' as location_id,
  doc->>'formSubmissionId' as form_submission_id,
  doc->>'dateCreated' as date_created
FROM public.couchdb where doc @> '{"type":"Event"}';

CREATE INDEX i_event_base_entity_id  ON event (base_entity_id);


CREATE MATERIALIZED VIEW vaccination AS
SELECT
  doc->>'baseEntityId' as base_entity_id,
  doc->>'eventDate' as event_date,
  doc->>'providerId' as provider_id,
  doc->>'locationId' as location_id,
  doc->>'dateCreated' as date_created,
  doc->'obs'->0->>'formSubmissionField' as vaccine,
  doc->'obs'->0->'values'->>0 as v_date,
  doc->'obs'->1->>'formSubmissionField' as dose,
  doc->'obs'->1->'values'->>0 as dose_value
FROM public.couchdb where doc @> '{"type":"Event", "eventType":"Vaccination"}';

CREATE INDEX i_vaccination_base_entity_id  ON vaccination (base_entity_id);

CREATE MATERIALIZED VIEW weight AS
SELECT
  doc->>'baseEntityId' as base_entity_id,
  doc->>'eventDate' as event_date,
  doc->>'providerId' as provider_id,
  doc->>'locationId' as location_id,
  doc->>'dateCreated' as date_created,
  doc->'obs'->0->'values'->>0 as weight,
  doc->'obs'->1->'values'->>0 as zscore
FROM public.couchdb where doc @> '{"type":"Event", "eventType":"Growth Monitoring"}';

CREATE INDEX i_weight_base_entity_id  ON weight (base_entity_id);


CREATE MATERIALIZED VIEW birth_event AS
SELECT
  doc->>'baseEntityId' as base_entity_id,
  doc->>'eventDate' as event_date,
  doc->>'providerId' as provider_id,
  doc->>'locationId' as location_id,
  doc->>'dateCreated' as date_created
FROM public.couchdb where doc @> '{"type":"Event", "eventType":"Birth Registration"}';;


CREATE MATERIALIZED VIEW birth_event_obs AS
SELECT doc->> 'baseEntityId' as base_entity_id,
       elements ->> 'formSubmissionField' as form_submission_field,
       elements -> 'values'->>0 as value
FROM public.couchdb
  CROSS JOIN jsonb_array_elements(doc->'obs') elements WHERE doc @> '{"type":"Event", "eventType":"Birth Registration"}';

CREATE INDEX i_birth_event_obs_base_entity_id  ON birth_event_obs (base_entity_id);
CREATE INDEX i_birth_event_obs_form_submission_field  ON birth_event_obs (form_submission_field);

CREATE MATERIALIZED VIEW client AS
SELECT
  doc->>'baseEntityId' as base_entity_id,
  doc->>'dateCreated' as date_created,
  doc->'identifiers'->>'ZEIR_ID' as zeir_id,
  doc->>'firstName' as first_name,
  doc->>'middleName' as middle_name,
  doc->>'lastName' as last_name,
  doc->>'gender' as gender,
  doc->>'birthdate' as birth_date,
  doc->'addresses'->0->'addressFields'->>'address3' as health_facility,
  doc->'addresses'->0->'addressFields'->>'address2' as residential_address,
  doc->'attributes'->>'Home_Facility' as home_facility,
  doc->'relationships'->'mother'->>0 as mother
FROM public.couchdb where doc @> '{"type":"Client"}';;

CREATE UNIQUE INDEX ui_client_bed
  ON client (base_entity_id);

#refreshing the views to fetch updates from couchdb
CREATE OR REPLACE FUNCTION refresh_all_materialized_views(schema_arg TEXT DEFAULT 'public')
RETURNS INT AS $$
DECLARE
r RECORD;
BEGIN
RAISE NOTICE 'Refreshing materialized view in schema %', schema_arg;
FOR r IN SELECT matviewname FROM pg_matviews WHERE schemaname = schema_arg
LOOP
RAISE NOTICE 'Refreshing %.%', schema_arg, r.matviewname;
EXECUTE 'REFRESH MATERIALIZED VIEW ' || schema_arg || '.' || r.matviewname;
END LOOP;

RETURN 1;
END
$$ LANGUAGE plpgsql;


