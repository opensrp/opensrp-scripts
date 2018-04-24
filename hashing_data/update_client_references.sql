DO $$
  DECLARE clients_cursor CURSOR FOR
  SELECT * from ids_mapping;
  rec RECORD;
BEGIN
    OPEN clients_cursor;
    LOOP
      FETCH clients_cursor into rec;
      EXIT WHEN NOT FOUND;

      RAISE NOTICE 'baseEntityId %',rec.original_id;
      --Update events

      UPDATE core.event_metadata SET base_entity_id=rec.generated_id WHERE base_entity_id=rec.original_id;

      UPDATE core.event SET json=jsonb_set(json,'{baseEntityId}',concat('"',rec.generated_id,'"')::jsonb,FALSE )
      where id IN (SELECT event_id FROM core.event_metadata WHERE base_entity_id=rec.original_id);

      --Update actions

      UPDATE core.action_metadata SET base_entity_id=rec.generated_id WHERE base_entity_id=rec.original_id;

      UPDATE core.action SET json=jsonb_set(json,'{baseEntityId}',concat('"',rec.generated_id,'"')::jsonb,FALSE )
      where id IN (SELECT action_id FROM core.action_metadata WHERE base_entity_id=rec.original_id);

       --Update alerts

      UPDATE core.alert_metadata SET base_entity_id=rec.generated_id WHERE base_entity_id=rec.original_id;

      UPDATE core.alert SET json=jsonb_set(json,'{entityId}',concat('"',rec.generated_id,'"')::jsonb,FALSE )
      where id IN (SELECT alert_id FROM core.alert_metadata WHERE base_entity_id=rec.original_id);


       --Update multimedia

      UPDATE core.multi_media SET case_id=rec.generated_id WHERE case_id=rec.original_id;

    END LOOP;
END;
$$
