-- creating TABLES for mVacc variables and ETL process

DROP TABLE IF EXISTS mvacc_mother;
CREATE TABLE mvacc_mother (
  mother_id          SERIAL,
  m_zeir_id          VARCHAR(50) UNIQUE,
  mother_first_name  VARCHAR(100),
  mother_second_name VARCHAR(100),
  phone_number       VARCHAR(15),
  rapidpro_uuid      VARCHAR(100),
  PRIMARY KEY (mother_id)
);

CREATE INDEX i_mother_id ON mvacc_mother (mother_id);
CREATE INDEX i_rapidpro_uuid ON mvacc_mother (rapidpro_uuid);

DROP TABLE IF EXISTS mvacc_child_mother_map;
CREATE TABLE mvacc_child_mother_map (
  child_mother_map_id  SERIAL,
  mother_id            INTEGER REFERENCES mvacc_mother(mother_id),
  zeir_id              VARCHAR(15) UNIQUE,
  PRIMARY KEY (child_mother_map_id)
);
CREATE INDEX i_child_mother_map_id ON mvacc_child_mother_map (child_mother_map_id);
CREATE INDEX i_mother ON mvacc_child_mother_map (mother_id);


DROP TABLE IF EXISTS mvacc_variables;
CREATE TABLE mvacc_variables (
  varial_id  SERIAL,
  key            VARCHAR(50) UNIQUE,
  value          VARCHAR(500),
  PRIMARY KEY (varial_id)
);
CREATE INDEX i_varial_id ON mvacc_variables (varial_id);
CREATE INDEX i_key ON mvacc_variables (key);
