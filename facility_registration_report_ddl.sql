CREATE DATABASE IF NOT EXISTS path_zambia_etl;

DROP TABLE if exists path_zambia_etl.facility_registration_report;


CREATE TABLE path_zambia_etl.facility_registration_report (
 person_id int(11) NOT NULL,
 zeir_id varchar(45) DEFAULT NULL,
 first_name varchar(45) DEFAULT NULL,
 last_name varchar(45) DEFAULT NULL,
 gender varchar(10) DEFAULT NULL,
 dob date DEFAULT NULL,
 date_first_seen datetime DEFAULT NULL,
 timestamp_of_registration datetime DEFAULT NULL,
 facility_id int(11) DEFAULT NULL,
 district varchar(100) DEFAULT NULL,
 province varchar(100) DEFAULT NULL,
 facility_name varchar(100) DEFAULT NULL,
 provider_id varchar(10) DEFAULT NULL,
 provider_name varchar(100) DEFAULT NULL,
 place_of_birth varchar(100) DEFAULT NULL,
 health_facility varchar(100) DEFAULT NULL,
 residential_area varchar(100) DEFAULT NULL,
 hiv_exposure varchar(45) DEFAULT NULL,
  PRIMARY KEY (person_id)
);

