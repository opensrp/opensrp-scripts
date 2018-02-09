-- Truncate the facility_registration_report flat table for new extract
TRUNCATE TABLE facility_registration_report;
INSERT INTO facility_registration_report (
  zeir_id, gender, dob, date_first_seen, timestamp_of_registration, facility_id, facility_name, provider_id, provider_name,
  place_of_birth, health_facility, residential_area
)
  SELECT DISTINCT ON (CLIENT.zeir_id)
    zeir_id,
    CLIENT.gender,
    CLIENT.birth_date :: TIMESTAMP :: DATE,
    dfs.value,
    CLIENT.date_created :: TIMESTAMP(0),
    COALESCE((loc.location_id), tl.location_id),
    CASE WHEN COALESCE((loc.name), tln.name) SIMILAR TO 'so %|we %'
      THEN substring(COALESCE((loc.name), tln.name) FROM 4)
    ELSE COALESCE((loc.name), tln.name) END,
    COALESCE((usr.person_id :: VARCHAR), bev.provider_id),
    CASE WHEN usr.person_id IS NOT NULL
      THEN
        CASE
        WHEN prv.name IS NULL
          THEN CONCAT(pname.given_name, ' ', pname.family_name)
        ELSE prv.name END
    ELSE bev.provider_id END,
    cn.name,
    CASE COALESCE((locfob.name), bfn.value)
    WHEN 'Other'
      THEN bfnl.value
    ELSE
      CASE WHEN COALESCE((locfob.name), bfn.value) SIMILAR TO 'so %|we %'
        THEN substring(COALESCE((locfob.name), bfn.value) FROM 4)
      ELSE COALESCE((locfob.name), bfn.value)
      END END,
    CLIENT.residential_address
  FROM public.client CLIENT
    JOIN public.birth_event bev ON bev.base_entity_id = CLIENT.base_entity_id
    LEFT JOIN public.birth_event_obs dfs ON (CLIENT.base_entity_id = dfs.base_entity_id AND
                                             dfs.form_submission_field = 'First_Health_Facility_Contact')
    LEFT JOIN public.birth_event_obs hmf ON (CLIENT.base_entity_id = hmf.base_entity_id AND
                                             hmf.form_submission_field = 'Home_Facility')
    LEFT JOIN public.birth_event_obs bfn ON (CLIENT.base_entity_id = bfn.base_entity_id AND
                                             bfn.form_submission_field = 'Birth_Facility_Name')
    LEFT JOIN public.birth_event_obs pob ON (CLIENT.base_entity_id = pob.base_entity_id AND
                                             pob.form_submission_field = 'Place_Birth')
    LEFT JOIN public.birth_event_obs bfnl ON (CLIENT.base_entity_id = bfnl.base_entity_id AND
                                              bfnl.form_submission_field = 'Birth_Facility_Name_Other')
    LEFT JOIN public.location loc ON loc.uuid = bev.location_id
    LEFT JOIN public.concept_name cn ON (cn.concept_id :: VARCHAR =
                                         (SELECT substring(pob.value FROM 0 FOR position('A' IN pob.value))) AND
                                         cn.locale = 'en')
    LEFT JOIN public.location locfob ON locfob.uuid = bfn.value
    LEFT JOIN public.users usr ON LOWER(usr.username) = LOWER(bev.provider_id)
    LEFT JOIN public.provider prv ON prv.person_id = usr.person_id
    LEFT JOIN public.person_name pname ON pname.person_id = usr.person_id
    LEFT JOIN public.team_member tm ON tm.person_id = usr.person_id
    LEFT JOIN public.member_location tl ON tl.team_member_id = tm.team_member_id
    LEFT JOIN public.location tln ON tln.location_id = tl.location_id
    LEFT JOIN public.location_tag_map ltm ON ltm.location_id = COALESCE((loc.location_id), tl.location_id)
  WHERE usr.username <> 'biddemo';
UPDATE
  facility_registration_report frr
SET
  facility_tag_id = location_tag_id
FROM location_tag_map aa
WHERE (aa.location_id = frr.facility_id AND location_tag_id = 4);
UPDATE
  facility_registration_report frr
SET
  facility_tag_id = location_tag_id
FROM location_tag_map aa
WHERE (aa.location_id = frr.facility_id AND location_tag_id = 5);
UPDATE
  facility_registration_report frr
SET district = loc.parent_location
FROM location loc
WHERE loc.location_id = frr.facility_id;
UPDATE
  facility_registration_report frr
SET
  district = loc.parent_location
FROM location loc
WHERE loc.location_id = frr.district :: INTEGER AND facility_tag_id = 5;
UPDATE
  facility_registration_report frr
SET
  district = loc.name,
  province = loc.parent_location
FROM location loc
WHERE loc.location_id = frr.district :: INTEGER;
UPDATE
  facility_registration_report frr
SET
  province = loc.name
FROM location loc
WHERE loc.location_id = frr.province :: INTEGER;