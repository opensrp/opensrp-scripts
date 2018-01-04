
#creating FOREIGN TABLES to get data from openmrs for concepts, users and location this tables
CREATE FOREIGN TABLE location (
location_id integer,
name varchar(255)  DEFAULT '',
description varchar(255),
address1 varchar(255),
address2 varchar(255),
city_village varchar(255),
state_province varchar(255),
postal_code varchar(50),
country varchar(50),
latitude varchar(50),
longitude varchar(50),
creator integer ,
date_created varchar(50),
county_district varchar(255),
address3 varchar(255),
address4 varchar(255),
address5 varchar(255),
address6 varchar(255),
retired smallint ,
retired_by integer,
date_retired varchar(50),
retire_reason varchar(255),
parent_location integer,
uuid char(38),
changed_by integer,
date_changed varchar(50))
SERVER mysql_server
OPTIONS (dbname 'openmrs', table_name 'location');

#GRANT ALL PRIVILEGES ON TABLE ﻿location_tag_map TO ﻿﻿﻿﻿etlgenerator;
CREATE FOREIGN TABLE location_tag_map (
location_id integer,
location_tag_id integer)
SERVER mysql_server
OPTIONS (dbname 'openmrs', table_name 'location_tag_map');


CREATE FOREIGN TABLE users (
user_id integer,
system_id varchar(50),
username varchar(50),
password varchar(128),
salt varchar(128),
secret_question varchar(255),
secret_answer varchar(255),
creator integer,
date_created varchar(50),
changed_by integer,
date_changed datetime,
person_id integer,
retired integer,
retired_by integer,
date_retired varchar(50),
retire_reason varchar(255),
uuid char(38)
) SERVER mysql_server
OPTIONS (dbname 'openmrs', table_name 'users');

CREATE FOREIGN TABLE concept_name (
concept_id integer,
name varchar(255),
locale varchar(50),
creator integer,
date_created varchar(50),
concept_name_id integer,
voided smallint,
voided_by integer,
date_voided varchar(50),
void_reason varchar(255),
uuid char(38),
concept_name_type varchar(50),
locale_preferred smallint
)
SERVER mysql_server
OPTIONS (dbname 'openmrs', table_name 'concept_name');


CREATE FOREIGN TABLE provider (
provider_id integer,
person_id integer,
name varchar(255),
identifier varchar(255),
creator integer ,
date_created datetime ,
changed_by integer,
date_changed datetime,
retired smallint,
retired_by integer,
date_retired datetime,
retire_reason varchar(255),
uuid char(38))
SERVER mysql_server
OPTIONS (dbname 'openmrs', table_name 'provider');

CREATE FOREIGN TABLE person_name (
person_name_id integer,
preferred smallint,
person_id integer,
prefix varchar(50),
given_name varchar(50),
middle_name varchar(50),
family_name_prefix varchar(50),
family_name varchar(50),
family_name2 varchar(50),
family_name_suffix varchar(50),
degree varchar(50),
creator integer,
date_created varchar(50),
voided varchar(50),
voided_by integer,
date_voided varchar(50),
void_reason varchar(255),
changed_by integer,
date_changed varchar(50),
uuid char(38))
SERVER mysql_server
OPTIONS (dbname 'openmrs', table_name 'person_name');
