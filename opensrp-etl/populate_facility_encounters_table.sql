
-- Truncate the encounter flat table for new extract
TRUNCATE ec_encounter;
INSERT INTO ec_encounter (
  encounter_date, zeir_id, gender, dob, mother_id, child_hiv_expo, fac_id, provider_id, child_weighed,
  child_weight
)
  SELECT
    gm.EVENT_DATE :: TIMESTAMP :: DATE,
    cl.zeir_id,
    cl.gender,
    cl.BIRTH_DATE :: TIMESTAMP :: DATE,
    clm.m_zeir_id,
    CASE WHEN hivex.value IS NOT NULL
      THEN CASE WHEN hivex.value = '703AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
        THEN 'YES'
           ELSE 'NO' END END,
    coalesce((loc.location_id), member_location.location_id),
    coalesce(usr.person_id::VARCHAR, gm.provider_id),
    CASE WHEN gmo.form_submission_field = 'Weight_Kgs'
      THEN 1 END,
    CASE WHEN gmo.form_submission_field = 'Weight_Kgs'
      THEN gmo.value::DOUBLE PRECISION END

  FROM growth_monitoring_obs gmo
    JOIN growth_monitoring gm ON gm.growth_monitoring_id = gmo.growth_monitoring_obs_id
    LEFT JOIN client cl ON cl.base_entity_id = gm.base_entity_id
    LEFT JOIN client clm ON clm.base_entity_id = cl.mother
    LEFT JOIN public.birth_event_obs hivex ON (gm.base_entity_id = hivex.base_entity_id AND
                                               hivex.form_submission_field = 'PMTCT_Status')
    LEFT JOIN location loc ON loc.uuid = gm.location_id
    LEFT JOIN users usr ON LOWER(usr.username) = LOWER(gm.provider_id)
    LEFT JOIN team_member team_member ON team_member.person_id = usr.person_id
    LEFT JOIN member_location member_location ON member_location.team_member_id = team_member.team_member_id
  WHERE gmo.form_submission_field = 'Weight_Kgs';
UPDATE
  ec_encounter enc
SET
  z_score      = gmo.value::DOUBLE PRECISION
FROM growth_monitoring_obs gmo
WHERE gmo.growth_monitoring_obs_id = enc.encounter_id AND gmo.form_submission_field = 'Z_Score_Weight_Age';

INSERT INTO ec_encounter (
  encounter_date, zeir_id, gender, dob, mother_id, child_hiv_expo, fac_id, provider_id, BCG1, OPV0, OPV1, PCV1, Penta1, Rota1, OPV2, PCV2, Penta2, Rota2, OPV3, PCV3, Penta3, Measles1,
  MR1, OPV4, Measles2, MR2, BCG2
)
  SELECT
    vac.EVENT_DATE :: TIMESTAMP :: DATE,
    cl.zeir_id,
    cl.gender,
    cl.BIRTH_DATE :: TIMESTAMP :: DATE,
    clm.m_zeir_id,
     CASE WHEN hivex.value IS NOT NULL
      THEN CASE WHEN hivex.value = '703AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
        THEN 'YES'
           ELSE 'NO' END END,
    coalesce((loc.location_id), member_location.location_id),
    coalesce(usr.person_id::VARCHAR,vac.provider_id),
    CASE WHEN vac_obs.form_submission_field = 'bcg'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'opv_0'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'opv_1'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'pcv_1'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'penta_1'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'rota_1'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'opv_2'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'pcv_2'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'penta_2'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'rota_2'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'opv_3'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'pcv_3'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'penta_3'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'measles_1'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'mr_1'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'opv_4'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'measles_2'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'mr_2'
      THEN 1 END,
    CASE WHEN vac_obs.form_submission_field = 'bcg_2'
      THEN 1 END
  FROM vaccination_obs vac_obs
    JOIN vaccination vac ON vac.vaccination_id = vac_obs.vaccination_obs_id
    JOIN client cl ON cl.base_entity_id = vac.base_entity_id
    LEFT JOIN client clm ON clm.base_entity_id = cl.mother
    LEFT JOIN birth_event_obs hivex
      ON (vac.base_entity_id = hivex.base_entity_id AND hivex.form_submission_field = 'PMTCT_Status')
    LEFT JOIN location loc ON loc.uuid = vac.location_id
    LEFT JOIN users usr ON LOWER(usr.username) = LOWER(vac.provider_id)
    LEFT JOIN team_member team_member ON team_member.person_id = usr.person_id
    LEFT JOIN member_location member_location ON member_location.team_member_id = team_member.team_member_id
  WHERE vac_obs.form_submission_field NOT LIKE '%_dose';


INSERT INTO ec_encounter (
  encounter_date, zeir_id, gender, dob, mother_id, child_hiv_expo, fac_id, provider_id, vitamin_a, mebendezol, ITN
)
SELECT
  rs.EVENT_DATE :: TIMESTAMP :: DATE,
  cl.zeir_id,
  cl.gender,
  cl.BIRTH_DATE :: TIMESTAMP :: DATE,
  clm.m_zeir_id,
   CASE WHEN hivex.value IS NOT NULL
      THEN CASE WHEN hivex.value = '703AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
        THEN 'YES'
           ELSE 'NO' END END,
  coalesce((loc.location_id), member_location.location_id),
  coalesce(usr.person_id::VARCHAR,rs.provider_id),
  CASE WHEN rso.form_submission_field LIKE 'vit_a%' AND rso.form_submission_field NOT LIKE '%dose' AND
            rso.value LIKE '1065%'
    THEN 1 END,
  CASE WHEN rso.form_submission_field LIKE 'deworming_%' AND rso.form_submission_field NOT LIKE '%dose' AND
            rso.value LIKE '1065%'
    THEN 1 END,
  CASE WHEN rso.form_submission_field LIKE 'itn_%' AND rso.form_submission_field NOT LIKE '%dose' AND
            rso.value LIKE '1065%'
    THEN 1 END

FROM recurring_service_obs rso
  JOIN recurring_service rs ON rs.service_id = rso.recurring_service_obs_id
  LEFT JOIN client cl ON cl.base_entity_id = rs.base_entity_id
  LEFT JOIN client clm ON clm.base_entity_id = cl.mother
  LEFT JOIN birth_event_obs hivex ON (rs.base_entity_id = hivex.base_entity_id AND
                                      hivex.form_submission_field = 'PMTCT_Status')
  LEFT JOIN location loc ON loc.uuid = rs.location_id
  LEFT JOIN users usr ON LOWER(usr.username) = LOWER(rs.provider_id)
  LEFT JOIN team_member team_member ON team_member.person_id = usr.person_id
  LEFT JOIN member_location member_location ON member_location.team_member_id = team_member.team_member_id;

DELETE FROM ec_encounter
WHERE (child_weight IS NULL AND z_score IS NULL AND BCG1 IS NULL AND OPV0 IS NULL AND OPV1 IS NULL AND Penta1 IS NULL AND
      Rota1 IS NULL AND OPV2 IS NULL AND PCV2 IS NULL AND Penta2 IS NULL AND Rota2 IS NULL AND OPV3 IS NULL AND
      PCV3 IS NULL AND Penta3 IS NULL AND Measles1 IS NULL AND MR1 IS NULL AND OPV4 IS NULL AND Measles2 IS NULL AND
      MR2 IS NULL AND BCG2 IS NULL AND vitamin_a IS NULL AND mebendezol IS NULL AND ITN IS NULL) OR zeir_id IS NULL OR provider_id = '2';


-- RUN UPDATES FOR LOCATION/NAMES
TRUNCATE location_hierarchy;
INSERT INTO location_hierarchy(location_id) SELECT DISTINCT fac_id from ec_encounter;
UPDATE
  location_hierarchy lh
SET
  location_tag_id = lti.location_tag_id
FROM location_tag_map lti
WHERE (lti.location_id = lh.location_id and lti.location_tag_id =5);

UPDATE
  location_hierarchy lh
SET
  location_tag_id = lti.location_tag_id
FROM location_tag_map lti
WHERE (lti.location_id = lh.location_id and lti.location_tag_id =4);

UPDATE
  location_hierarchy lh
SET  district_id  = loc.parent_location,
  facility_name = (CASE WHEN loc.name SIMILAR TO 'so %|we %' THEN substring(loc.name from 4) ELSE loc.name END),
district_name  = loc.parent_location
FROM location loc
WHERE loc.location_id = lh.location_id;

UPDATE
  location_hierarchy lh
SET
  district_id  = loc.parent_location
FROM location loc
WHERE lh.location_tag_id = 5 and loc.location_id = lh.district_name::integer;

UPDATE
  location_hierarchy lh
SET
  district_name  = (CASE WHEN loc.name SIMILAR TO 'so %|we %' THEN substring(loc.name from 4) ELSE loc.name END),
  province_id = loc.parent_location
  FROM location loc
WHERE loc.location_id = lh.district_id;

UPDATE
  location_hierarchy lh
SET
  province_name = (CASE WHEN loc.name SIMILAR TO 'so %|we %' THEN substring(loc.name from 4) ELSE loc.name END)
FROM location loc
WHERE loc.location_id = lh.province_id;

UPDATE
  ec_encounter enc
SET
  fac_name      = lh.facility_name,
  district_name = lh.district_name,
  province_name = lh.province_name
FROM location_hierarchy lh
WHERE lh.location_id = enc.fac_id;

-- Update Provider

TRUNCATE provider_names;
INSERT INTO provider_names(user_id) SELECT DISTINCT provider_id FROM ec_encounter;

UPDATE
  provider_names pn
SET
  provider_name  = pr.name
FROM provider pr
WHERE pr.person_id::VARCHAR = pn.user_id;

UPDATE
  provider_names pn
SET
  provider_name  = CONCAT(pname.given_name, ' ', pname.family_name)
FROM person_name pname
WHERE pname.person_id::VARCHAR = pn.user_id AND provider_name ISNULL;
UPDATE
  ec_encounter enc
SET
  provider_name  = coalesce(pn.provider_name,enc.provider_id)
FROM provider_names pn
WHERE pn.user_id = enc.provider_id;

TRUNCATE facility_encounters;
INSERT INTO facility_encounters(
  encounter_date,zeir_id,gender,date_of_birth, mother_id,child_hiv_expo,facility_name,district_name,province_name,
  provider_name,visit_id,child_weighed,child_weight,z_score,bcg_1,opv_0,opv_1,pcv_1, pentavalent_1,rota_1,opv_2,pcv_2,
  pentavalent_2,rota_2,opv_3,pcv_3,pentavalent_3,measles_1,mr_1,opv_4,measles_2,mr_2,bcg_2,vitamin_a,mebendezol,itn
)
    SELECT
    encounter_date::DATE,zeir_id,gender,dob,mother_id,child_hiv_expo,fac_name,district_name,province_name,provider_name,
    DENSE_RANK() OVER(ORDER BY encounter_date,zeir_id,provider_id),
    child_weighed,child_weight,z_score,BCG1,OPV0,OPV1,PCV1,Penta1,Rota1,OPV2,PCV2,Penta2,Rota2,
    OPV3,PCV3,Penta3,Measles1,MR1,OPV4,Measles2,MR2,BCG2,vitamin_a,mebendezol,ITN FROM ec_encounter
GROUP BY encounter_date,zeir_id,gender,dob,mother_id,child_hiv_expo,fac_name,district_name,province_name,provider_id,provider_name,
    child_weighed,child_weight,z_score,BCG1,OPV0,OPV1,PCV1,Penta1,Rota1,OPV2,PCV2,Penta2,Rota2,
    OPV3,PCV3,Penta3,Measles1,MR1,OPV4,Measles2,MR2,BCG2,vitamin_a,mebendezol,ITN;
