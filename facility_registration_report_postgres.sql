select client.zeir_id as "ZEIR ID",
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
        prv.name as "Provider name",
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
   inner join public.birth_event bev on bev.base_entity_id = client.base_entity_id
   left join public.birth_event_obs dfs on (client.base_entity_id = dfs.base_entity_id and
                                            dfs.form_submission_field='First_Health_Facility_Contact')
   left join public.birth_event_obs hmf on (client.base_entity_id = hmf.base_entity_id and
                                            hmf.form_submission_field='Home_Facility')
   left join public.birth_event_obs bfn on (client.base_entity_id = bfn.base_entity_id and
                                            bfn.form_submission_field='Birth_Facility_Name')
   left join public.birth_event_obs pob on (client.base_entity_id = pob.base_entity_id and
                                            pob.form_submission_field='Place_Birth')

   left join public.birth_event_obs bfnl on (client.base_entity_id = bfnl.base_entity_id and
                                             bfnl.form_submission_field='Birth_Facility_Name_Other')

   left join public.location loc on loc.uuid = bev.location_id
   left join public.concept_name cn on (cn.concept_id::varchar =
   (SELECT substring(pob.value from 0 for position('A' in pob.value))) and cn.locale='en')
   left join public.location locfob on locfob.uuid = bfn.value


   left join public.users usr on LOWER(usr.username) = LOWER(bev.provider_id)


   left join public.provider prv on prv.person_id = usr.person_id

   left join public.location_tag_map ltm on ltm.location_id = loc.location_id

   left join public.location dist_four on dist_four.location_id = loc.parent_location
   left join public.location dist_five_step on dist_five_step.location_id = dist_four.parent_location

   left join public.location dist_four_prov on dist_four_prov.location_id = dist_four.parent_location
   left join public.location dist_five_step_prov on dist_five_step_prov.location_id = dist_five_step.parent_location

 group by client.zeir_id,client.gender,client.birth_date,dfs.value,client.date_created,
   loc.location_id,loc.name,hmf.value,ltm.location_tag_id,dist_four.name,dist_five_step.name,
   dist_four_prov.name,dist_five_step_prov.name,prv.person_id,prv.name,cn.name,locfob.name,bfn.value,
   client.residential_address,bfnl.value,usr.person_id order by client.date_created asc


