-- Create facility_encounter_report table to hold the different encounters

DROP TABLE IF EXISTS ec_encounter;
CREATE TABLE ec_encounter (
  id              SERIAL,
  encounter_id    VARCHAR(50),
  encounter_date  VARCHAR(40)      DEFAULT NULL,
  zeir_id         VARCHAR(100)     DEFAULT NULL,
  base_entity_id  VARCHAR(100)     DEFAULT NULL,
  gender          VARCHAR(10)      DEFAULT NULL,
  dob             DATE             DEFAULT NULL,
  mother_id       VARCHAR(100)     DEFAULT NULL,
  child_hiv_expo  VARCHAR(100)     DEFAULT NULL,
  fac_id          INTEGER          DEFAULT NULL,
  location_tag_id INTEGER          DEFAULT NULL,
  fac_name        VARCHAR(100)     DEFAULT NULL,
  district_id     INTEGER          DEFAULT NULL,
  district_name   VARCHAR(100)     DEFAULT NULL,
  province_id     INTEGER          DEFAULT NULL,
  province_name   VARCHAR(100)     DEFAULT NULL,
  provider_id     VARCHAR(100)     DEFAULT NULL,
  provider_name   VARCHAR(100)     DEFAULT NULL,
  child_weighed   SMALLINT         DEFAULT NULL,
  child_weight    DOUBLE PRECISION DEFAULT NULL,
  z_score         DOUBLE PRECISION DEFAULT NULL,
  BCG1            SMALLINT         DEFAULT NULL,
  OPV0            SMALLINT         DEFAULT NULL,
  OPV1            SMALLINT         DEFAULT NULL,
  PCV1            SMALLINT         DEFAULT NULL,
  Penta1          SMALLINT         DEFAULT NULL,
  Rota1           SMALLINT         DEFAULT NULL,
  OPV2            SMALLINT         DEFAULT NULL,
  PCV2            SMALLINT         DEFAULT NULL,
  Penta2          SMALLINT         DEFAULT NULL,
  Rota2           SMALLINT         DEFAULT NULL,
  OPV3            SMALLINT         DEFAULT NULL,
  PCV3            SMALLINT         DEFAULT NULL,
  Penta3          SMALLINT         DEFAULT NULL,
  Measles1        SMALLINT         DEFAULT NULL,
  MR1             SMALLINT         DEFAULT NULL,
  OPV4            SMALLINT         DEFAULT NULL,
  Measles2        SMALLINT         DEFAULT NULL,
  MR2             SMALLINT         DEFAULT NULL,
  BCG2            SMALLINT         DEFAULT NULL,
  vitamin_a       SMALLINT         DEFAULT NULL,
  mebendezol      SMALLINT         DEFAULT NULL,
  ITN             SMALLINT         DEFAULT NULL,
  PRIMARY KEY (id)
);


DROP TABLE IF EXISTS location_hierarchy;
CREATE TABLE location_hierarchy (
  location_id     INTEGER,
  location_tag_id INTEGER DEFAULT NULL,
  district_id     INTEGER DEFAULT NULL,
  province_id     INTEGER DEFAULT NULL,
  facility_name   VARCHAR(250) DEFAULT NULL,
  district_name   VARCHAR(250) DEFAULT NULL,
  province_name   VARCHAR(250) DEFAULT NULL
);

DROP TABLE IF EXISTS provider_names;
CREATE TABLE provider_names (
  user_id       VARCHAR(100),
  provider_name VARCHAR(250)
);

DROP TABLE IF EXISTS hiv_expo;
CREATE TABLE hiv_expo (
  base_entity_id VARCHAR(100),
  expo           VARCHAR(5),
  mother         VARCHAR(100)
);

-- Create facility_registration_report table to hold the different registrations (Not being used adopted andres structure)
DROP TABLE IF EXISTS facility_registration_report;
CREATE TABLE facility_registration_report (
  zeir_id                   VARCHAR(100) DEFAULT NULL,
  gender                    VARCHAR(10)  DEFAULT NULL,
  dob                       VARCHAR(40)  DEFAULT NULL,
  date_first_seen           VARCHAR(40)  DEFAULT NULL,
  timestamp_of_registration VARCHAR(40)  DEFAULT NULL,
  facility_id               INTEGER      DEFAULT NULL,
  facility_tag_id           INTEGER      DEFAULT NULL,
  district                  VARCHAR(100) DEFAULT NULL,
  province                  VARCHAR(100) DEFAULT NULL,
  facility_name             VARCHAR(100) DEFAULT NULL,
  provider_id               VARCHAR(10)  DEFAULT NULL,
  provider_name             VARCHAR(100) DEFAULT NULL,
  place_of_birth            VARCHAR(100) DEFAULT NULL,
  health_facility           VARCHAR(100) DEFAULT NULL,
  residential_area          VARCHAR(100) DEFAULT NULL
);


-- Create facility_registration_report table to hold the different registrations (Andres structure)
DROP TABLE IF EXISTS birth_registration;
CREATE TABLE birth_registration (
  zeir_id                   VARCHAR(250) DEFAULT NULL,
  gender                    VARCHAR(250)  DEFAULT NULL,
  date_of_birth             DATE  DEFAULT NULL,
  date_first_seen           DATE  DEFAULT NULL,
  timestamp_of_registration TIMESTAMP  DEFAULT NULL,
  facility_id               INTEGER      DEFAULT NULL,
  facility_name             VARCHAR(250) DEFAULT NULL,
  facility_tag_id           INTEGER      DEFAULT NULL,
  district                  VARCHAR(250) DEFAULT NULL,
  province                  VARCHAR(250) DEFAULT NULL,
  registration_facility     VARCHAR(250) DEFAULT NULL,
  provider_id               VARCHAR(10)  DEFAULT NULL,
  provider_name             VARCHAR(250) DEFAULT NULL,
  place_of_birth            VARCHAR(250) DEFAULT NULL,
  facility_of_birth         VARCHAR(250) DEFAULT NULL,
  residential_area          VARCHAR(250) DEFAULT NULL
);

DROP TABLE IF EXISTS facility_encounters;
CREATE TABLE facility_encounters (
  encounter_id   SERIAL,
  encounter_date DATE         NOT NULL,
  zeir_id        VARCHAR(100) NOT NULL,
  gender         VARCHAR(15)  NOT NULL,
  date_of_birth  DATE,
  mother_id      VARCHAR(100),
  child_hiv_expo VARCHAR(5),
  facility_name  VARCHAR(250),
  district_name  VARCHAR(250),
  province_name  VARCHAR(250),
  provider_name  VARCHAR(250),
  visit_id       INTEGER      NOT NULL,
  child_weighed  SMALLINT DEFAULT NULL,
  child_weight   DOUBLE PRECISION,
  z_score        DOUBLE PRECISION,
  bcg_1          SMALLINT DEFAULT NULL,
  opv_0          SMALLINT DEFAULT NULL,
  opv_1          SMALLINT DEFAULT NULL,
  pcv_1          SMALLINT DEFAULT NULL,
  pentavalent_1  SMALLINT DEFAULT NULL,
  rota_1         SMALLINT DEFAULT NULL,
  opv_2          SMALLINT DEFAULT NULL,
  pcv_2          SMALLINT DEFAULT NULL,
  pentavalent_2  SMALLINT DEFAULT NULL,
  rota_2         SMALLINT DEFAULT NULL,
  opv_3          SMALLINT DEFAULT NULL,
  pcv_3          SMALLINT DEFAULT NULL,
  pentavalent_3  SMALLINT DEFAULT NULL,
  measles_1      SMALLINT DEFAULT NULL,
  mr_1           SMALLINT DEFAULT NULL,
  opv_4          SMALLINT DEFAULT NULL,
  measles_2      SMALLINT DEFAULT NULL,
  mr_2           SMALLINT DEFAULT NULL,
  bcg_2          SMALLINT DEFAULT NULL,
  vitamin_a      SMALLINT DEFAULT NULL,
  mebendezol     SMALLINT DEFAULT NULL,
  itn            SMALLINT DEFAULT NULL
);


