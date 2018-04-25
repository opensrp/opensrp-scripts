DELETE FROM facility_encounters WHERE ctid NOT IN
(SELECT max(ctid) FROM facility_encounters GROUP BY zeir_id,provider_name,bcg_1,opv_0,opv_1,pentavalent_1,rota_1
,opv_2,pcv_2,pentavalent_2,rota_2,opv_3,pentavalent_3,measles_1,mr_1,mr_1,opv_4,measles_2,mr_2,bcg_2,vitamin_a,mebendezol,itn);

