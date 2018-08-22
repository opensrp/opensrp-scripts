-- Create unicef rapidpro tables

DROP TABLE IF EXISTS contact;
CREATE TABLE contact (
  id_serial    SERIAL,
  pregnant     BOOLEAN                  DEFAULT NULL,
  child        BOOLEAN                  DEFAULT NULL,
  unsubscribed BOOLEAN                  DEFAULT NULL,
  ID           VARCHAR(500) UNIQUE,
  reg_date     TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  mother_age   INTEGER                  DEFAULT NULL,
  duration     INTEGER                  DEFAULT NULL,
  country      VARCHAR(100)             DEFAULT NULL,
  language     VARCHAR(100)             DEFAULT NULL,
  child_age    INTEGER                  DEFAULT NULL,
  edd          TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  child_dob    TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  PRIMARY KEY (id_serial)
);
-- indexing contact
CREATE INDEX ic_pregnant ON contact (pregnant);
CREATE INDEX ic_child  ON contact (child);
CREATE INDEX ic_reg_date ON contact (reg_date);
CREATE INDEX ic_mother_age ON contact (mother_age);
CREATE INDEX ic_country ON contact (country);
CREATE INDEX ic_language ON contact (language);
CREATE INDEX ic_child_age ON contact (child_age);
CREATE INDEX ic_child_dob ON contact (child_dob);
CREATE INDEX ic_edd ON contact (edd);
DROP TABLE IF EXISTS message;
CREATE TABLE message (
  id_serial    SERIAL,
  message_id   NUMERIC UNIQUE,
  contact_id   VARCHAR(500),
  contact_name VARCHAR(500),
  direction    VARCHAR(50)   DEFAULT NULL,
  text         VARCHAR(5000) DEFAULT NULL,
  msg_date     TIMESTAMP WITH TIME ZONE,
  PRIMARY KEY (id_serial)
);
-- indexing message
CREATE INDEX im_message_id ON message (message_id);
CREATE INDEX im_contact_id  ON message (contact_id);
CREATE INDEX im_contact_name ON message (contact_name);
CREATE INDEX im_direction ON message (direction);
CREATE INDEX im_msg_date ON message (msg_date);

DROP TABLE IF EXISTS message_label;
CREATE TABLE message_label (
  id_serial  SERIAL,
  message_id NUMERIC,
  label_name VARCHAR(500),
  contact_id VARCHAR(500),
  msg_date   TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  PRIMARY KEY (id_serial)
);
-- indexing message_label
CREATE INDEX il_message_id ON message_label (message_id);
CREATE INDEX il_label_name  ON message_label (label_name);
CREATE INDEX il_contact_id ON message_label (contact_id);
CREATE INDEX il_msg_date ON message_label (msg_date);

DROP TABLE IF EXISTS variables;
CREATE TABLE variables (
  id_serial    SERIAL,
  name   VARCHAR(50) UNIQUE,
  value   VARCHAR(500),
  PRIMARY KEY (id_serial)
);
-- indexing variables
CREATE INDEX iv_name ON variables (name);
CREATE INDEX iv_value  ON variables (value);

