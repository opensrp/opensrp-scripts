SELECT m_zeir_id          AS "m_zeir_id",
       mother_first_name  AS "Mother’s First Name",
       mother_second_name AS "Mother’s Last Name",
       phone_number       AS "Phone number",
       rapidpro_uuid      AS "RapidProUuid",
       mc.zeir_id AS "Zeir_id"

FROM mvacc_mother mm
       left join mvacc_child_mother_map mc on mc.mother_id = mm.mother_id;