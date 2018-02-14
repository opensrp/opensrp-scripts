/* Data Quality Analysis Scripts

This document contains scripts for data quality analysis that can be run in PostgreSQL */


/*---------CLIENT ANALYSIS---------*/

/* C1: Identify clients in the Client materialized view with duplicate zeir_id

Description: This query identifies duplicates in zeir_ids. m_zeir_id should be unique in the client table. Duplicates signify a problem that need to be addressed.

Columns: zeir_id, first_name, middle_name, last_name, gender, birth_date, death_date, health facility, date_created
*/
SELECT a.zeir_id, a.first_name, a.middle_name, a.last_name, a.gender, a.birth_date, a.death_date, a.health_facility, a.date_created
FROM client a
JOIN (
	SELECT b.zeir_id, count(b.zeir_id) AS num
	FROM client b
	GROUP BY b.zeir_id
	HAVING count(b.zeir_id)>1
) b on a.zeir_id = b.zeir_id
ORDER BY a.zeir_id;


/* C2: Identify mothers in the Client materialized view with duplicate m_meir_id

Description: This query identifies duplicates in m_zeir_ids. m_zeir_id should be unique in the client table. Duplicates signify a problem that need to be addressed.

Columns: m_zeir_id, first_name, middle_name, last_name, gender, birth_date, death_date, health_facility, date_created
*/
SELECT a.m_zeir_id, a.first_name, a.middle_name, a.last_name, a.gender, a.birth_date, a.death_date, a.health_facility, a.date_created
FROM client a
JOIN (
	SELECT b.m_zeir_id, count(b.m_zeir_id) AS num
	FROM client b
	GROUP BY b.m_zeir_id
	HAVING count(b.m_zeir_id)>1
) b on a.m_zeir_id = b.m_zeir_id
ORDER BY a.m_zeir_id;

/* C3: Identify clients with NULL zeir_id and m_zeir_id

Description: This query identifies clients with NULL values in both the zeir_id and m_zeir_id. Both of these fields should not be null.

Columns: zeir_id, m_zeir_id, first_name, middle_name, last_name, gender, birth_date, death_date, health_facility, date_created
*/
SELECT zeir_id, m_zeir_id, first_name, middle_name, last_name, gender, birth_date, death_date, health_facility, date_created
FROM client
WHERE zeir_id IS NULL AND m_zeir_id IS NULL;

/* C4: Identify clients with both zeir_id and m_zeir_id

Description: This query identifies clients with values in both the zeir_id and m_zeir_id. Both of these fields should not be filled.

Columns: zeir_id, m_zeir_id, first_name, middle_name, last_name, gender, birth_date, death_date, health_facility, date_created
*/
SELECT zeir_id, m_zeir_id, first_name, middle_name, last_name, gender, birth_date, death_date, health_facility, date_created
FROM client
WHERE zeir_id IS NOT NULL AND m_zeir_id IS NOT NULL;

/*--------- VACCINATION EVENT ANALYSIS---------*/

/* E1: Identify ZEIR IDs of children who have more than one immunization by immunization_type

Description: This query identifies zeir_ids of children who have multiple immunizations of the immunization type. We need to identify if a single child
has had multiple vaccine events for the same immunization type anywhere in the system. If a specific child has more than one immunization, it's likely a bug in the system.
The ETL process already has a good example script that was used to generate this.

Logic: The vaccination materialized view identifies the vaccination event metadata, the vaccination_obs materialized view contains the obs of the vaccination event linked by primary key and the client materialized view identifies the client information.
https://github.com/OpenSRP/path-zambia-etl/blob/master/opensrp-etl/populate_facility_encounters_table.sql

Columns: ZEIR_ID, Vaccine type (VAX_TYPE), NUM which is a count of the number of vaccines in the system
*/

SELECT  cl.zeir_id AS ZEIR_ID, vac_obs.form_submission_field AS VAX_TYPE, count(vac_obs.form_submission_field) AS NUM
FROM vaccination_obs vac_obs
JOIN vaccination vac ON vac.vaccination_id = vac_obs.vaccination_obs_id
JOIN client cl ON cl.base_entity_id = vac.base_entity_id
WHERE
	(vac_obs.form_submission_field = 'bcg' OR
	vac_obs.form_submission_field = 'opv_0' OR
	vac_obs.form_submission_field = 'opv_1' OR
	vac_obs.form_submission_field = 'pcv_1' OR
	vac_obs.form_submission_field = 'penta_1' OR
	vac_obs.form_submission_field = 'rota_1' OR
	vac_obs.form_submission_field = 'opv_2' OR
	vac_obs.form_submission_field = 'pcv_2' OR
	vac_obs.form_submission_field = 'penta_2' OR
	vac_obs.form_submission_field = 'rota_2' OR
	vac_obs.form_submission_field = 'opv_3' OR
	vac_obs.form_submission_field = 'pcv_3' OR
	vac_obs.form_submission_field = 'penta_3' OR
	vac_obs.form_submission_field = 'measles_1' OR
	vac_obs.form_submission_field = 'mr_1' OR
	vac_obs.form_submission_field = 'opv_4' OR
	vac_obs.form_submission_field = 'measles_2' OR
	vac_obs.form_submission_field = 'mr_2' OR
	vac_obs.form_submission_field = 'bcg_2')
GROUP BY cl.zeir_id, vac_obs.form_submission_field
HAVING count(vac_obs.form_submission_field)>1;