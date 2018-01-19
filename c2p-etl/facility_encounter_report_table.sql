-- Create facility_encounter_report table to hold the different encounters

CREATE TABLE facility_encounter_report (
  id SERIAL,
  encounter_id varchar(50),
  encounter_date varchar(40) DEFAULT NULL,
  zeir_id varchar(100) DEFAULT NULL,
  gender varchar(10) DEFAULT NULL,
  dob date DEFAULT NULL,
  mother_id varchar(26) DEFAULT NULL,
  child_hiv_expo varchar(100) DEFAULT NULL,
  fac_id integer DEFAULT NULL,
  fac_name varchar(100) DEFAULT NULL,
  district_id integer DEFAULT NULL,
  district_name varchar(100) DEFAULT NULL,
  province_id integer DEFAULT NULL,
  province_name varchar(100) DEFAULT NULL,
  provider_id integer DEFAULT NULL,
  provider_name varchar(100) DEFAULT NULL,
  child_weighed smallint DEFAULT NULL,
  child_weight varchar(45) DEFAULT NULL,
  z_score varchar(100) DEFAULT NULL,
  BCG1 smallint DEFAULT NULL,
  OPV0 smallint DEFAULT NULL,
  OPV1 smallint DEFAULT NULL,
  PCV1 smallint DEFAULT NULL,
  Penta1 smallint DEFAULT NULL,
  Rota1 smallint DEFAULT NULL,
  OPV2 smallint DEFAULT NULL,
  PCV2 smallint DEFAULT NULL,
  Penta2 smallint DEFAULT NULL,
  Rota2 smallint DEFAULT NULL,
  OPV3 smallint DEFAULT NULL,
  PCV3 smallint DEFAULT NULL,
  Penta3 smallint DEFAULT NULL,
  Measles1 smallint DEFAULT NULL,
  MR1 smallint DEFAULT NULL,
  OPV4 smallint DEFAULT NULL,
  Measles2 smallint DEFAULT NULL,
  MR2 smallint DEFAULT NULL,
  BCG2 smallint DEFAULT NULL,
  vitamin_a smallint DEFAULT NULL,
  mebendezol smallint DEFAULT NULL,
  PRIMARY KEY (id)
);

-- Create facility_registration_report table to hold the different registrations
﻿DROP TABLE IF EXISTS facility_registration_report;
CREATE TABLE facility_registration_report (
  zeir_id varchar(45) DEFAULT NULL,
  gender varchar(10) DEFAULT NULL,
  dob varchar(40) DEFAULT NULL,
  date_first_seen varchar(40) DEFAULT NULL,
  timestamp_of_registration varchar(40) DEFAULT NULL,
  facility_id integer DEFAULT NULL,
  facility_tag_id integer DEFAULT NULL,
  district varchar(100) DEFAULT NULL,
  province varchar(100) DEFAULT NULL,
  facility_name varchar(100) DEFAULT NULL,
  provider_id varchar(10) DEFAULT NULL,
  provider_name varchar(100) DEFAULT NULL,
  place_of_birth varchar(100) DEFAULT NULL,
  health_facility varchar(100) DEFAULT NULL,
  residential_area varchar(100) DEFAULT NULL
);


﻿CREATE TABLE facility_registration_report (
  zeir_id,gender,dob,date_first_seen,timestamp_of_registration,facility_id,
  facility_tag_id,district,province,facility_name,provider_id,provider_name,
  place_of_birth,health_facility,residential_area,hiv_exposure
);
