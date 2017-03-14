SELECT "Droping existing facility activity report etl table";

DROP TABLE if exists openmrs.facility_activity_report;

SELECT "Recreating facility activity etl table";

CREATE TABLE facility_activity_report (
  encounter_id INT(11) not null primary key,
  zeir_id VARCHAR(50),
  patient_id INT(11),
  gender VARCHAR(50),
  birthdate DATE,
  location_name VARCHAR(255),
  encounter_date DATE,
  child_register_card_no VARCHAR(255),
  lt_12_months_male INT(11),
  lt_12_months_female INT(11),
  btwn_12_59_months_male INT(11),
  btwn_12_59_months_female INT(11),
  from_outside_catchment_area INT(11),
  0_23_months_weighed INT(11),
  24_59_months_weighed INT(11),
  0_23_months_no_weight_gain INT(11),
  24_59_months_no_weight_gain INT(11),
  bcg_dose_lt_1yr INT(11),
  opv_dose_0 INT(11),
  opv_dose_1 INT(11),
  opv_dose_2 INT(11),
  opv_dose_3 INT(11),
  opv_dose_4 INT(11),
  pentavalent_dose_1 INT(11),
  pentavalent_dose_2 INT(11),
  pentavalent_dose_3 INT(11),
  pcv_dose_1 INT(11),
  pcv_dose_2 INT(11),
  pcv_dose_3 INT(11),
  rv_dose_1 INT(11),
  rv_dose_2 INT(11),
  measles_mr_dose_1 INT(11),
  immunised_fully INT(11),
  measles_mr_dose_2 INT(11)
)
