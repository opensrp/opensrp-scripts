SET @@group_concat_max_len = 1000000;

-- Get duplicate relationships ids
SELECT DISTINCT relationship_ids FROM (
select group_concat(relationship_id) as relationship_ids, count(*) as count from relationship r
where r.relationship =2 group by person_b having count >1 order by count desc) a;

SET @@group_concat_max_len = 1024;