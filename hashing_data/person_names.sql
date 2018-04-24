create table if not exists person_names
(
	id serial not null constraint person_names_pkey primary key,
	name varchar
);

\COPY person_names(name) FROM '/Users/coder/Projects/path-zambia-etl/hashing_data/person_names.csv' DELIMITER ',' CSV HEADER;
