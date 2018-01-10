-- Truncate the encounter flat table for new extract
TRUNCATE TABLE facility_encounter_report;

INSERT INTO facility_encounter_report (
  encounter_id,encounter_date,zeir_id,gender,dob,mother_id,child_hiv_expo,fac_id,fac_name,district_id,district_name,province_id,
  province_name,provider_id,provider_name,BCG1,OPV0,OPV1,PCV1,Penta1,Rota1,OPV2,PCV2,Penta2,Rota2,OPV3,PCV3,Penta3,Measles1,
  MR1,OPV4,Measles2,MR2,BCG2
)
  SELECT
    vacc.vaccination_id,vacc.v_date::timestamp::date,cl.zeir_id,cl.gender,
    cl.birth_date::timestamp::date,clm.zeir_id,
    CASE
    WHEN cn.name IS NOT NULL
      THEN
        CASE WHEN cn.name ='POSITIVE'
          THEN 'YES'
        ELSE 'NO'
        END
    END as "Child HIV Exposure",
    coalesce((loc.location_id),0) as "Facility ID",

    CASE WHEN loc.name LIKE 'so %'
      THEN substring(loc.name from 4)
    ELSE loc.name
    END as "Facility Name",

    CASE ltm.location_tag_id
    WHEN 4
      THEN
        dist_four.location_id
    WHEN 5
      THEN
        dist_five_step.location_id

    END as "District ID",

    CASE ltm.location_tag_id
    WHEN 4 THEN
      CASE WHEN dist_four.name LIKE 'so %'
        THEN substring(dist_four.name from 4)
      ELSE dist_four.name
      END
    WHEN 5 THEN
      CASE WHEN dist_five_step.name LIKE 'so %'
        THEN substring(dist_five_step.name from 4)
      ELSE dist_five_step.name
      END
    ELSE 'other'
    END as "District Name",

    CASE ltm.location_tag_id
    WHEN 4
      THEN
        dist_four_prov.location_id
    WHEN 5
      THEN
        dist_five_step_prov.location_id

    END as "Province ID",
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
    END as "Province Name",
    usr.person_id as "Provider ID",
    CASE
    WHEN prv.name IS NULL
      THEN
        CONCAT(pname.given_name,' ',pname.family_name)
    ELSE prv.name
    END as "Provider name",

    CASE  WHEN vacc.vaccine ='bcg' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='opv_0' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='opv_1' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='pcv_1' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='penta_1' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='rota_1' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='opv_2' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='pcv_2' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='penta_2' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='rota_2' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='opv_3' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='pcv_3' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='penta_3' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='measles_1' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='mr_1' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='opv_4' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='measles_2' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='mr_2' THEN 1 ELSE NULL END,
    CASE  WHEN vacc.vaccine ='bcg_2' THEN 1 ELSE NULL END

  FROM public.vaccination vacc
    LEFT JOIN public.client cl ON cl.base_entity_id = vacc.base_entity_id
    LEFT JOIN public.client clm ON clm.base_entity_id = cl.mother
    LEFT JOIN public.birth_event_obs hivex ON (vacc.base_entity_id = hivex.base_entity_id AND
                                               hivex.form_submission_field='PMTCT_Status')
    LEFT JOIN public.concept_name cn ON (cn.concept_id::varchar =
    (SELECT substring(hivex.value from 0 for position('A' in hivex.value))) AND cn.locale='en' AND concept_name_type='FULLY_SPECIFIED')
    LEFT JOIN public.location loc ON loc.uuid = vacc.location_id
    LEFT JOIN public.location_tag_map ltm ON ltm.location_id = loc.location_id
    LEFT JOIN public.location dist_four ON dist_four.location_id = loc.parent_location
    LEFT JOIN public.location dist_five_step ON dist_five_step.location_id = dist_four.parent_location
    LEFT JOIN public.location dist_four_prov ON dist_four_prov.location_id = dist_four.parent_location
    LEFT JOIN public.location dist_five_step_prov ON dist_five_step_prov.location_id = dist_five_step.parent_location
    LEFT JOIN public.users usr ON LOWER(usr.username) = LOWER(vacc.provider_id)
    LEFT JOIN public.provider prv ON prv.person_id = usr.person_id
    LEFT JOIN public.person_name pname ON pname.person_id = usr.person_id
  GROUP BY vacc.vaccination_id,vacc.v_date,cl.zeir_id,cl.gender,cl.birth_date,clm.zeir_id,cn.name,loc.location_id,loc.name,
    ltm.location_tag_id,dist_four.location_id,dist_five_step.location_id,dist_four.name,dist_five_step.name,dist_four_prov.location_id,
    dist_four_prov.name,dist_five_step_prov.location_id,dist_five_step_prov.name,usr.person_id,prv.name,pname.given_name,pname.family_name,vacc.vaccine;

-- Extract weight events
INSERT INTO facility_encounter_report (
  encounter_id,encounter_date,zeir_id,gender,dob,mother_id,child_hiv_expo,fac_id,
  fac_name,district_id,district_name,province_id,province_name,provider_id,provider_name,
  child_weighed,child_weight,z_score
)
  SELECT
    weight.weight_id,weight.event_date::timestamp::date,cl.zeir_id,cl.gender,
    cl.birth_date::timestamp::date,clm.zeir_id,
    CASE
    WHEN cn.name IS NOT NULL
      THEN
        CASE WHEN cn.name ='POSITIVE'
          THEN 'YES'
        ELSE 'NO'
        END
    END as "Child HIV Exposure",

    coalesce((loc.location_id),0) as "Facility ID",
    CASE WHEN loc.name LIKE 'so %'
      THEN substring(loc.name from 4)
    ELSE loc.name
    END as "Facility Name",

    CASE ltm.location_tag_id
    WHEN 4
      THEN
        dist_four.location_id
    WHEN 5
      THEN
        dist_five_step.location_id

    END as "District ID",

    CASE ltm.location_tag_id
    WHEN 4 THEN
      CASE WHEN dist_four.name LIKE 'so %'
        THEN substring(dist_four.name from 4)
      ELSE dist_four.name
      END
    WHEN 5 THEN
      CASE WHEN dist_five_step.name LIKE 'so %'
        THEN substring(dist_five_step.name from 4)
      ELSE dist_five_step.name
      END
    ELSE 'other'
    END as "District Name",

    CASE ltm.location_tag_id
    WHEN 4
      THEN
        dist_four_prov.location_id
    WHEN 5
      THEN
        dist_five_step_prov.location_id

    END as "Province ID",
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
    END as "Province Name",
    usr.person_id as "Provider ID",
    CASE
    WHEN prv.name IS NULL
      THEN
        CONCAT(pname.given_name,' ',pname.family_name)
    ELSE prv.name
    END as "Provider name",
    CASE  WHEN weight.weight IS NOT NULL THEN 1 ELSE NULL END,
    weight.weight,
    weight.zscore

  from public.weight
    LEFT JOIN public.client cl ON cl.base_entity_id = weight.base_entity_id
    LEFT JOIN public.client clm ON clm.base_entity_id = cl.mother
    LEFT JOIN public.birth_event_obs hivex ON (weight.base_entity_id = hivex.base_entity_id AND
                                               hivex.form_submission_field='PMTCT_Status')
    LEFT JOIN public.concept_name cn ON (cn.concept_id::varchar =
    (SELECT substring(hivex.value from 0 for position('A' in hivex.value))) AND cn.locale='en' AND concept_name_type='FULLY_SPECIFIED')
    LEFT JOIN public.location loc ON loc.uuid = weight.location_id
    LEFT JOIN public.location_tag_map ltm ON ltm.location_id = loc.location_id
    LEFT JOIN public.location dist_four ON dist_four.location_id = loc.parent_location
    LEFT JOIN public.location dist_five_step ON dist_five_step.location_id = dist_four.parent_location
    LEFT JOIN public.location dist_four_prov ON dist_four_prov.location_id = dist_four.parent_location
    LEFT JOIN public.location dist_five_step_prov ON dist_five_step_prov.location_id = dist_five_step.parent_location
    LEFT JOIN public.users usr ON LOWER(usr.username) = LOWER(weight.provider_id)
    LEFT JOIN public.provider prv ON prv.person_id = usr.person_id
    LEFT JOIN public.person_name pname ON pname.person_id = usr.person_id
  GROUP BY weight.weight_id,weight.event_date,cl.zeir_id,cl.gender,cl.birth_date,
    clm.zeir_id,cn.name,loc.location_id,loc.name,ltm.location_tag_id,dist_four.location_id,
    dist_five_step.location_id,dist_four.name,dist_five_step.name,dist_four_prov.location_id,
    dist_four_prov.name,dist_five_step_prov.location_id,dist_five_step_prov.name,usr.person_id,
    prv.name,pname.given_name,pname.family_name,weight.weight,weight.zscore;


-- Extract Recurring Services
INSERT INTO facility_encounter_report (
  encounter_id,encounter_date,zeir_id,gender,dob,mother_id,child_hiv_expo,fac_id,fac_name,district_id,district_name,province_id,
  province_name,provider_id,provider_name,vitamin_a,mebendezol
)

  SELECT
    rs.service_id,rs.event_date::timestamp::date,cl.zeir_id,cl.gender,cl.birth_date::timestamp::date,clm.zeir_id,
    CASE
    WHEN cn.name IS NOT NULL
      THEN
        CASE WHEN cn.name ='POSITIVE'
          THEN 'YES'
        ELSE 'NO'
        END
    END as "Child HIV Exposure",

    coalesce((loc.location_id),0) as "Facility ID",
    CASE WHEN loc.name LIKE 'so %'
      THEN substring(loc.name from 4)
    ELSE loc.name
    END as "Facility Name",

    CASE ltm.location_tag_id
    WHEN 4
      THEN
        dist_four.location_id
    WHEN 5
      THEN
        dist_five_step.location_id

    END as "District ID",
    CASE ltm.location_tag_id
    WHEN 4 THEN
      CASE WHEN dist_four.name LIKE 'so %'
        THEN substring(dist_four.name from 4)
      ELSE dist_four.name
      END
    WHEN 5 THEN
      CASE WHEN dist_five_step.name LIKE 'so %'
        THEN substring(dist_five_step.name from 4)
      ELSE dist_five_step.name
      END
    ELSE 'other'
    END as "District Name",

    CASE ltm.location_tag_id
    WHEN 4
      THEN
        dist_four_prov.location_id
    WHEN 5
      THEN
        dist_five_step_prov.location_id

    END as "Province ID",
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
    END as "Province Name",
    usr.person_id as "Provider ID",
    CASE
    WHEN prv.name IS NULL
      THEN
        CONCAT(pname.given_name,' ',pname.family_name)
    ELSE prv.name
    END as "Provider name" ,
    CASE  WHEN rs.vaccine LIKE 'vit_a%' THEN 1 ELSE NULL END,
    CASE  WHEN rs.vaccine LIKE 'deworming_1%' THEN 1 ELSE NULL END

  from public.recurring_service rs
    LEFT JOIN public.client cl ON cl.base_entity_id = rs.base_entity_id
    LEFT JOIN public.client clm ON clm.base_entity_id = cl.mother
    LEFT JOIN public.birth_event_obs hivex ON (rs.base_entity_id = hivex.base_entity_id AND
                                               hivex.form_submission_field='PMTCT_Status')
    LEFT JOIN public.concept_name cn ON (cn.concept_id::varchar =
    (SELECT substring(hivex.value from 0 for position('A' in hivex.value))) AND cn.locale='en' AND concept_name_type='FULLY_SPECIFIED')

    LEFT JOIN public.location loc ON loc.uuid = rs.location_id
    LEFT JOIN public.location_tag_map ltm ON ltm.location_id = loc.location_id
    LEFT JOIN public.location dist_four ON dist_four.location_id = loc.parent_location
    LEFT JOIN public.location dist_five_step ON dist_five_step.location_id = dist_four.parent_location
    LEFT JOIN public.location dist_four_prov ON dist_four_prov.location_id = dist_four.parent_location
    LEFT JOIN public.location dist_five_step_prov ON dist_five_step_prov.location_id = dist_five_step.parent_location
    LEFT JOIN public.users usr ON LOWER(usr.username) = LOWER(rs.provider_id)
    LEFT JOIN public.provider prv ON prv.person_id = usr.person_id
    LEFT JOIN public.person_name pname ON pname.person_id = usr.person_id

  GROUP BY rs.service_id,rs.event_date,cl.zeir_id,cl.gender,cl.birth_date,clm.zeir_id,
    cn.name,loc.location_id,loc.name,ltm.location_tag_id,dist_four.location_id,
    dist_five_step.location_id,dist_four.name,dist_five_step.name,dist_four_prov.location_id,
    dist_four_prov.name,dist_five_step_prov.location_id,dist_five_step_prov.name,usr.person_id,
    prv.name,pname.given_name,pname.family_name,rs.vaccine;


-- Clean up unused encounter rows
DELETE FROM facility_encounter_report
WHERE child_weight IS NULL AND child_weighed IS NOT NULL AND z_score IS NULL AND BCG1 IS NULL AND OPV0 IS NULL AND OPV1 IS NULL AND
      PCV1 IS NULL AND Penta1 IS NULL AND Rota1 IS NULL AND OPV2 IS NULL AND PCV2 IS NULL AND Penta2 IS NULL AND
      Rota2 IS NULL AND OPV3 IS NULL AND PCV3 IS NULL AND Penta3 IS NULL AND Measles1 IS NULL AND MR1 IS NULL AND
      OPV4 IS NULL AND Measles2 IS NULL AND MR2 IS NULL AND BCG2 IS NULL AND vitamin_a IS NULL AND mebendezol IS NULL;
