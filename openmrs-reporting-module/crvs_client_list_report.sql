/* Definition: This report lists all children in the system that are not void, their demographic information and their mother's information
   in a single table.
   
   Setup:
   - Load the following query into the OpenMRS reporting module as a SQL dataset definition.
   - The underlying data model was built for the ZEIR implementation. Different implementations will need to modify the address template,
     registration forms and other variables

   Note: This report is meant for demonstration purposes only and is not performant at scale.
*/
SELECT
   p.person_id,
   pid.ZEIR_ID,
   pn.given_name,
   pn.middle_name,
   pn.family_name,
   p.gender,
   p.birthdate,
   bl.birth_location,
   ad.province,
   ad.district,
   ad.residential_area,
   ad.residential_address,
   ad.physical_landmark,
   ad.health_facility,
   pa.date_created,
   m.m_person_id,
   m.m_given_name,
   m.m_family_name,
   m.m_birthdate,
   m.m_gender
 FROM person p
   JOIN patient pa ON pa.patient_id = p.person_id
   INNER JOIN person_name pn ON pn.person_id = p.person_id AND pn.voided = 0
   JOIN
	(
	SELECT
	 p.person_id as m_person_id,
	 p.gender as m_gender,
	 p.birthdate as m_birthdate,
	 pn.given_name as m_given_name,
	 pn.family_name as m_family_name,
	 r.person_b,
	 concat(rt.a_is_to_b, " / ", rt.b_is_to_a) AS relationship_type
   FROM person p
	 JOIN person_name pn ON p.person_id = pn.person_id
	 LEFT JOIN relationship r ON p.person_id = r.person_a
	 JOIN relationship_type rt
	   ON r.relationship = rt.relationship_type_id
   WHERE r.person_b IN (SELECT patient_id
						FROM patient)
						ORDER BY p.person_id ASC
	) m ON m.person_b  = pa.patient_id
   JOIN
	(
	SELECT
		  pi.patient_id as patient_id,
		  max(if(pit.uuid = 'e31c3522-55c5-4335-9fb9-68398e861250', pi.identifier, NULL)) AS ZEIR_ID
		FROM patient_identifier pi
		  JOIN patient_identifier_type pit ON pi.identifier_type = pit.patient_identifier_type_id
		WHERE voided = 0
		GROUP BY pi.patient_id) pid ON pid.patient_id = pa.patient_id
   JOIN (SELECT
              ad.person_id as person_id,
              ad.state_province  AS province,
              ad.county_district AS district,
              ad.address3        AS residential_area,
              ad.address2        AS residential_address,
              ad.address1        AS physical_landmark,
              ad.address4        AS health_facility
            FROM person_address ad
            WHERE voided = 0
            GROUP BY ad.person_id) ad ON ad.person_id = pa.patient_id
   JOIN (SELECT *
            FROM
              (SELECT
                 o.person_id,
                 cn.name AS birth_location
               FROM obs o
			   JOIN concept_name cn ON o.value_coded = cn.concept_id AND cn.locale = 'en'
                                      AND cn.concept_name_type = 'FULLY_SPECIFIED'
               WHERE o.concept_id = 1572
               ORDER BY o.person_id ASC)
              a
            GROUP BY a.person_id) bl ON bl.person_id = pa.patient_id
 GROUP BY p.person_id;
