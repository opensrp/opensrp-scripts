CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS public.ids_mapping
(
    original_id VARCHAR,
    generated_id VARCHAR
);
CREATE INDEX ids_mapping_index ON public.ids_mapping (original_id, generated_id);


CREATE OR REPLACE FUNCTION  random_between(low integer, high integer)
  RETURNS integer
STRICT
LANGUAGE plpgsql
AS $$
BEGIN
   RETURN floor(random()* (high-low + 1) + low);
END;
$$;
