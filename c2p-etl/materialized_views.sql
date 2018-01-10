-- creating views to hold data extracted from json docs from couchDB

  CREATE MATERIALIZED VIEW event AS
  SELECT
    doc->>'_id' as event_id,
    doc->>'baseEntityId' as base_entity_id,
    doc->>'eventDate' as event_date,
    doc->>'eventType' as event_type,
    doc->>'providerId' as provider_id,
    doc->>'locationId' as location_id,
    doc->>'dateCreated' as date_created
  FROM public.couchdb where doc @> '{"type":"Event"}';

-- indexing
CREATE INDEX i_event_base_entity_id ON event (base_entity_id);
CREATE INDEX i_event_event_type ON event (event_type);
CREATE INDEX i_event_location_id ON event (location_id);
CREATE INDEX i_event_provider_id ON event (provider_id);
CREATE UNIQUE INDEX ui_event_id ON event (event_id);


CREATE MATERIALIZED VIEW vaccination AS
SELECT
  doc->>'_id' as vaccination_id,
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

-- indexing
CREATE INDEX i_vaccination_base_entity_id ON vaccination (base_entity_id);
CREATE INDEX i_vaccination_provider_id ON vaccination (provider_id);
CREATE INDEX i_vaccination_location_id ON vaccination (location_id);
CREATE INDEX i_vaccination_vaccine ON vaccination (vaccine);
CREATE UNIQUE INDEX ui_vaccination_id ON vaccination (vaccination_id);


CREATE MATERIALIZED VIEW weight AS
SELECT
  doc->>'_id' as weight_id,
  doc->>'baseEntityId' as base_entity_id,
  doc->>'eventDate' as event_date,
  doc->>'providerId' as provider_id,
  doc->>'locationId' as location_id,
  doc->>'dateCreated' as date_created,
  doc->'obs'->0->'values'->>0 as weight,
  doc->'obs'->1->'values'->>0 as zscore
FROM public.couchdb where doc @> '{"type":"Event", "eventType":"Growth Monitoring"}';

-- indexing
CREATE INDEX i_weight_base_entity_id ON weight (base_entity_id);
CREATE INDEX i_weight_provider_id ON weight (provider_id);
CREATE INDEX i_weight_location_id ON weight (location_id);
CREATE UNIQUE INDEX ui_weight_id ON weight (weight_id);


CREATE MATERIALIZED VIEW birth_event AS
SELECT
  doc->>'_id' as birth_event_id,
  doc->>'baseEntityId' as base_entity_id,
  doc->>'eventDate' as event_date,
  doc->>'providerId' as provider_id,
  doc->>'locationId' as location_id,
  doc->>'dateCreated' as date_created
FROM public.couchdb where doc @> '{"type":"Event", "eventType":"Birth Registration"}';

-- indexing
CREATE INDEX i_birth_event_id ON birth_event (base_entity_id);
CREATE INDEX i_location_id ON birth_event (location_id);
CREATE INDEX i_provider_id ON birth_event (provider_id);
CREATE UNIQUE INDEX ui_birth_event_id ON birth_event (birth_event_id);


CREATE MATERIALIZED VIEW birth_event_obs AS
SELECT
  doc->>'_id' as birth_event_obs_id,
  doc->> 'baseEntityId' as base_entity_id,
  elements ->> 'formSubmissionField' as form_submission_field,
  elements -> 'values'->>0 as value
FROM public.couchdb
  CROSS JOIN jsonb_array_elements(doc->'obs') elements WHERE doc @> '{"type":"Event", "eventType":"Birth Registration"}';

-- indexing
CREATE INDEX i_birth_event_obs_base_entity_id ON birth_event_obs (base_entity_id);
CREATE INDEX i_birth_event_obs_form_submission_field ON birth_event_obs (form_submission_field);
CREATE INDEX i_value ON birth_event_obs (value);
CREATE UNIQUE INDEX ui_birth_event_obs_id ON birth_event_obs (birth_event_obs_id,form_submission_field);

CREATE MATERIALIZED VIEW client AS
SELECT
  doc->>'_id' as client_id,
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
FROM public.couchdb where doc @> '{"type":"Client"}';

-- indexing
CREATE INDEX i_client_id ON client (base_entity_id);
CREATE INDEX i_mother_id ON client (mother);
CREATE UNIQUE INDEX ui_client_id ON client (client_id);


CREATE MATERIALIZED VIEW recurring_service AS
SELECT
  doc->>'_id' as service_id,
  doc->>'baseEntityId' as base_entity_id,
  doc->>'eventDate' as event_date,
  doc->>'providerId' as provider_id,
  doc->>'locationId' as location_id,
  doc->>'dateCreated' as date_created,
  doc->'obs'->0->>'formSubmissionField' as vaccine,
  doc->'obs'->0->'values'->>0 as v_date,
  doc->'obs'->1->>'formSubmissionField' as dose,
  doc->'obs'->1->'values'->>0 as dose_value
FROM public.couchdb where doc @> '{"type":"Event", "eventType":"Recurring Service"}';

-- indexing
CREATE INDEX i_recurring_service_base_entity_id ON recurring_service (base_entity_id);
CREATE INDEX i_recurring_service_provider_id ON recurring_service (provider_id);
CREATE INDEX i_recurring_service_location_id ON recurring_service (location_id);
CREATE INDEX i_recurring_service_vaccine ON recurring_service (vaccine);
CREATE UNIQUE INDEX ui_recurring_service_id ON recurring_service (service_id);
