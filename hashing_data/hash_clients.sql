DO $$
DECLARE
  --generated random hashed data
  DECLARE clients_cursor CURSOR FOR
  select  m.id cm_id,c.id c_id,fn.name first_name,ln.name last_name,
  to_char(date '2014-01-10' +
       random() * (date '2018-04-15' -
                   timestamp '2014-01-20'),'yyyy-mm-ddThh24:mi:ss.msZ') birth_date,
  random_between(10000000,99999999) unique_id,uuid_generate_v4() base_entity_id,
  uuid_generate_v4() openmrs_uuid,cm.base_entity_id original_id,relational_id
  from
  (select id,floor(random() * 100000 + 1) fname,floor(random() * 100000 + 1) lname
  from core.client_metadata)m
  join core.client_metadata cm on cm.id=m.id
  join core.client c on c.id=cm.client_id
  join person_names fn on fn.id=m.fname
  join person_names ln on ln.id=m.lname
  order by relational_id nulls FIRST
  FOR UPDATE;
  t_client   RECORD;
  v_mother   varchar;
BEGIN
 
  OPEN clients_cursor;
  LOOP
    FETCH clients_cursor into t_client;
    EXIT WHEN NOT FOUND;

    --store the mapping of ids to be used to update dependent references
    insert into ids_mapping(original_id, generated_id)
    VALUES (t_client.original_id,t_client.base_entity_id);

    select generated_id into v_mother from ids_mapping where original_id=t_client.relational_id;

    --hash client data on metadata
   update core.client_metadata set first_name=t_client.first_name, last_name=t_client.last_name,
     birth_date=t_client.birth_date,base_entity_id=t_client.base_entity_id,
     unique_id=t_client.unique_id, openmrs_uuid=t_client.openmrs_uuid,
     relational_id=v_mother
     where id=t_client.cm_id;

    --hash the client data on json
    update core.client set
      json= jsonb_set(
          jsonb_set(jsonb_set( jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(json,
          '{relationships,mother,0}',concat('"',v_mother,'"')::jsonb,false),
          '{identifiers,OPENMRS_UUID}',concat('"',t_client.openmrs_uuid,'"')::jsonb,false),
          '{identifiers,M_ZEIR_ID}',concat('"',t_client.unique_id,'"')::jsonb,false),
          '{identifiers,ZEIR_ID}',concat('"',t_client.unique_id,'"')::jsonb,false),
          '{baseEntityId}',concat('"',t_client.base_entity_id,'"')::jsonb,false),
          '{birthdate}',concat('"',t_client.birth_date,'"')::jsonb,false),
          '{lastName}',concat('"',t_client.last_name,'"')::jsonb,false),
          '{firstName}',concat('"',t_client.first_name,'"')::jsonb,false)
      where id=t_client.c_id;

    --hash attributes  their own on json
     update core.client set
      json=jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(json,
                '{attributes,Child_Register_Card_Number}',concat('"',random_between(10000000,99999999),'"')::jsonb,FALSE),
                '{attributes,Child_Birth_Certificate}',concat('"',random_between(10000,99999),'"')::jsonb,FALSE),
                '{attributes,Father_NRC_Number}',concat('"',random_between(100000000,999099999),'"')::jsonb,FALSE),
                '{attributes,CHW_Phone_Number}',concat('"0',random_between(10000000,99999999),'"')::jsonb,FALSE),
                '{attributes,Patient Image}',concat('"',uuid_generate_v4(),'"')::jsonb,FALSE),
                '{attributes,Home_Facility}',concat('"',uuid_generate_v4(),'"')::jsonb,FALSE),
                '{attributes,CHW_Name}',concat('"',uuid_generate_v4(),'"')::jsonb,FALSE)
    where id=t_client.c_id;

  END LOOP;
  CLOSE clients_cursor;

END$$;


