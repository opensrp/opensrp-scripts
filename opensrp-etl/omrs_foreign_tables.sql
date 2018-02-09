-- creating FOREIGN TABLES to get data from openmrs for concepts, users and location this tables

CREATE FOREIGN TABLE location (
location_id INTEGER,
NAME VARCHAR (255) DEFAULT '',
description VARCHAR (255),
address1 VARCHAR (255),
address2 VARCHAR (255),
city_village VARCHAR (255),
state_province VARCHAR (255),
postal_code VARCHAR (50),
country VARCHAR (50),
latitude VARCHAR (50),
longitude VARCHAR (50),
creator INTEGER,
date_created VARCHAR (50),
county_district VARCHAR (255),
address3 VARCHAR (255),
address4 VARCHAR (255),
address5 VARCHAR (255),
address6 VARCHAR (255),
retired SMALLINT,
retired_by INTEGER,
date_retired VARCHAR (50),
retire_reason VARCHAR (255),
parent_location INTEGER,
uuid CHAR (38),
changed_by INTEGER,
date_changed VARCHAR (50))
SERVER mysql_server
OPTIONS (dbname 'openmrs', TABLE_NAME 'location');

CREATE FOREIGN TABLE location_tag_map (
location_id INTEGER,
location_tag_id INTEGER )
SERVER mysql_server
OPTIONS (dbname 'openmrs', TABLE_NAME 'location_tag_map');


CREATE FOREIGN TABLE users (
user_id INTEGER,
system_id VARCHAR (50),
username VARCHAR (50),
PASSWORD VARCHAR (128),
salt VARCHAR (128),
secret_question VARCHAR (255),
secret_answer VARCHAR (255),
creator INTEGER,
date_created VARCHAR (50),
changed_by INTEGER,
date_changed VARCHAR (20),
person_id INTEGER,
retired INTEGER,
retired_by INTEGER,
date_retired VARCHAR (50),
retire_reason VARCHAR (255),
uuid CHAR (38)
) SERVER mysql_server
OPTIONS (dbname 'openmrs', TABLE_NAME 'users');

CREATE FOREIGN TABLE concept_name (
concept_id INTEGER,
NAME VARCHAR (255),
locale VARCHAR (50),
creator INTEGER,
date_created VARCHAR (50),
concept_name_id INTEGER,
voided SMALLINT,
voided_by INTEGER,
date_voided VARCHAR (50),
void_reason VARCHAR (255),
uuid CHAR (38),
concept_name_type VARCHAR (50),
locale_preferred SMALLINT
)
SERVER mysql_server
OPTIONS (dbname 'openmrs', TABLE_NAME 'concept_name');


CREATE FOREIGN TABLE provider (
provider_id INTEGER,
person_id INTEGER,
NAME VARCHAR (255),
identifier VARCHAR (255),
creator INTEGER,
date_created VARCHAR (20),
changed_by INTEGER,
date_changed VARCHAR (20),
retired SMALLINT,
retired_by INTEGER,
date_retired VARCHAR (20),
retire_reason VARCHAR (255),
uuid CHAR (38))
SERVER mysql_server
OPTIONS (dbname 'openmrs', TABLE_NAME 'provider');

CREATE FOREIGN TABLE person_name (
person_name_id INTEGER,
preferred SMALLINT,
person_id INTEGER,
prefix VARCHAR (50),
given_name VARCHAR (50),
middle_name VARCHAR (50),
family_name_prefix VARCHAR (50),
family_name VARCHAR (50),
family_name2 VARCHAR (50),
family_name_suffix VARCHAR (50),
degree VARCHAR (50),
creator INTEGER,
date_created VARCHAR (50),
voided VARCHAR (50),
voided_by INTEGER,
date_voided VARCHAR (50),
void_reason VARCHAR (255),
changed_by INTEGER,
date_changed VARCHAR (50),
uuid CHAR (38))
SERVER mysql_server
OPTIONS (dbname 'openmrs', TABLE_NAME 'person_name');


CREATE FOREIGN TABLE member_location (
team_member_id INTEGER,
location_id INTEGER )
SERVER mysql_server
OPTIONS (dbname 'openmrs', TABLE_NAME 'member_location');


CREATE FOREIGN TABLE team_member (
team_member_id INTEGER,
identifier VARCHAR (45),
team_id INTEGER,
person_id INTEGER,
join_date VARCHAR (20),
leave_date VARCHAR (20),
is_team_lead SMALLINT,
date_created VARCHAR (20),
creator INTEGER,
changed_by INTEGER,
date_changed VARCHAR (20),
voided SMALLINT,
voided_by INTEGER,
date_voided VARCHAR (20),
void_reason VARCHAR (255),
uuid VARCHAR (255))
SERVER mysql_server
OPTIONS (dbname 'openmrs', TABLE_NAME 'team_member');

