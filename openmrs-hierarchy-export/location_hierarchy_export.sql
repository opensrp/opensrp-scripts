-- Author: Rodgesr Andati

--
-- Query to get chw details from OpenMRS
--

select team_member.uuid as chw_id, team_member.identifier as chw_username, given_name, middle_name, family_name, birthdate, gender, team.name as team, team.uuid as team_id, team_role.name as team_role, location.name as assigned_location, location.uuid as location_id
from team_member inner join person on team_member.person_id = person.person_id
inner join person_name on person_name.person_id = person.person_id
inner join team on team.team_id = team_member.team_id
inner join team_role on team_role.team_role_id = team_member.team_role_id
inner join location on team.location_id = location.location_id;


--
-- Query to get location hierrachy from OpenMRS
--

SELECT t1.uuid AS village_id, t1.name AS village_name, t2.uuid AS ward_id, t2.name as ward_name, t3.uuid AS district_id, t3.name as district_name, t4.uuid AS province_id, t4.name as province_name
FROM location AS t1
LEFT JOIN location AS t2 ON t2.location_id = t1.parent_location
LEFT JOIN location AS t3 ON t3.location_id = t2.parent_location
LEFT JOIN location AS t4 ON t4.location_id = t3.parent_location
WHERE t1.location_id in 
(select location.location_id from location 
inner join location_tag_map on location.location_id = location_tag_map.location_id
inner join location_tag on location_tag.location_tag_id = location_tag_map.location_tag_id
where location_tag_map.location_tag_id = 2);

--- 2 in above query is the id of the lowest location level which could be village or health facility depending on the project.
--- To get the correct id for your project run :-
--- select location.uuid, location.name, location_tag.name as tag, location_tag.location_tag_id from location 
--- inner join location_tag_map on location.location_id = location_tag_map.location_id
--- inner join location_tag on location_tag.location_tag_id = location_tag_map.location_tag_id;

