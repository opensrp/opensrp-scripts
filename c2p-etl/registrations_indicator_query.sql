SELECT client.zeir_id as "ZEIR ID",
        client.gender as "Gender",
   client.birth_date::timestamp::date as "DOB",
        dfs.value as "Date first seen",
   client.date_created::TIMESTAMP(0) as "Timestamp of registration",
        coalesce((loc.location_id),0) as "Facility of registration ID",

        CASE WHEN coalesce((loc.name),hmf.value) LIKE 'so %'
          THEN substring(coalesce((loc.name),hmf.value) from 4)
        ELSE coalesce((loc.name),hmf.value)
        END as "Facility of registration name",

        CASE ltm.location_tag_id
        WHEN 4 THEN
          CASE WHEN dist_four.name LIKE 'so %'
            THEN substring(dist_four.name from 4)
          ELSE dist_four.name
          END
        WHEN 5 THEN
          CASE WHEN dist_five_step.name LIKE 'so %'
            THEN substring(dist_five_step.name from 4)
          ELSE dist_four.name
          END
        ELSE 'other'
        END as "District",

        CASE ltm.location_tag_id
        WHEN 4 THEN
          CASE WHEN dist_four_prov.name LIKE 'so %'
            THEN substring(dist_four_prov.name from 4)
          ELSE dist_four_prov.name
          END
        WHEN 5 THEN
          CASE WHEN dist_five_step_prov.name LIKE 'so %'
            THEN substring(dist_five_step_prov.name from 4)
          ELSE dist_five_step_prov.name
          END
        ELSE 'other'
        END as "Province",
  usr.person_id as "Provider ID",

        CASE
        WHEN prv.name IS NULL
          THEN
            CONCAT(pname.given_name,' ',pname.family_name)
        ELSE prv.name
        END as "Provider name",
  
   cn.name as "Place of birth",

        CASE coalesce((locfob.name),bfn.value)
        WHEN 'Other' THEN bfnl.value
        ELSE
          CASE WHEN coalesce((locfob.name),bfn.value) LIKE 'so %'
            THEN substring(coalesce((locfob.name),bfn.value) from 4)
          ELSE coalesce((locfob.name),bfn.value)
          END
        END as "Facility of Birth",
   client.residential_address as "Residential area"

 from public.client client
   JOIN public.birth_event bev ON bev.base_entity_id = client.base_entity_id
   LEFT JOIN public.birth_event_obs dfs ON (client.base_entity_id = dfs.base_entity_id AND
                                            dfs.form_submission_field='First_Health_Facility_Contact')
   LEFT JOIN public.birth_event_obs hmf ON (client.base_entity_id = hmf.base_entity_id AND
                                            hmf.form_submission_field='Home_Facility')
   LEFT JOIN public.birth_event_obs bfn ON (client.base_entity_id = bfn.base_entity_id AND
                                            bfn.form_submission_field='Birth_Facility_Name')
   LEFT JOIN public.birth_event_obs pob ON (client.base_entity_id = pob.base_entity_id AND
                                            pob.form_submission_field='Place_Birth')
   LEFT JOIN public.birth_event_obs bfnl ON (client.base_entity_id = bfnl.base_entity_id AND
                                             bfnl.form_submission_field='Birth_Facility_Name_Other')
   LEFT JOIN public.location loc ON loc.uuid = bev.location_id
   LEFT JOIN public.concept_name cn ON (cn.concept_id::varchar =
   (SELECT substring(pob.value from 0 for position('A' in pob.value))) AND cn.locale='en')
   LEFT JOIN public.location locfob ON locfob.uuid = bfn.value

   LEFT JOIN public.users usr ON LOWER(usr.username) = LOWER(bev.provider_id)
   LEFT JOIN public.provider prv ON prv.person_id = usr.person_id
   LEFT JOIN public.person_name pname ON pname.person_id = usr.person_id
   LEFT JOIN public.location_tag_map ltm ON ltm.location_id = loc.location_id
   LEFT JOIN public.location dist_four ON dist_four.location_id = loc.parent_location
   LEFT JOIN public.location dist_five_step ON dist_five_step.location_id = dist_four.parent_location
   LEFT JOIN public.location dist_four_prov ON dist_four_prov.location_id = dist_four.parent_location
   LEFT JOIN public.location dist_five_step_prov ON dist_five_step_prov.location_id = dist_five_step.parent_location

 GROUP BY client.zeir_id,client.gender,client.birth_date,dfs.value,client.date_created,
   loc.location_id,loc.name,hmf.value,ltm.location_tag_id,dist_four.name,dist_five_step.name,
   dist_four_prov.name,dist_five_step_prov.name,prv.person_id,prv.name,cn.name,locfob.name,bfn.value,
   client.residential_address,bfnl.value,usr.person_id,pname.family_name,pname.given_name ORDER BY client.date_created ASC


