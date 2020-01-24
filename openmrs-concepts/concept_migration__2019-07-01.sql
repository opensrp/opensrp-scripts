--Update concept_class table
alter table concept_class change date_created date_created datetime default CURRENT_TIMESTAMP;
alter table concept_class add column changed_by int(11) default 1;
alter table concept_class add column date_changed datetime default CURRENT_TIMESTAMP;

--Update concept_name_tag table
alter table concept_name_tag change date_created date_created datetime default CURRENT_TIMESTAMP;
alter table concept_name_tag add column changed_by int(11) default 1;
alter table concept_name_tag add column date_changed datetime default CURRENT_TIMESTAMP;

--Update concept_name table
alter table concept_name change date_created date_created datetime default CURRENT_TIMESTAMP;
alter table concept_name add column changed_by int(11) default 1;
alter table concept_name add column date_changed datetime default CURRENT_TIMESTAMP;

--Update concept_reference_source table
alter table concept_reference_source change date_created date_created datetime default CURRENT_TIMESTAMP;
alter table concept_reference_source add column changed_by int(11) default 1;
alter table concept_reference_source add column date_changed datetime default CURRENT_TIMESTAMP;
alter table concept_reference_source add column unique_id varchar(250) default NULL;
