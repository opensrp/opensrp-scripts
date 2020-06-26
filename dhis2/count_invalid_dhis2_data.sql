--
-- SP to count invalid records in dhis2 database
-- Invalid records prevents importing location data from dhis2 to OpenMRS.
--
CREATE FUNCTION invalid_data_count() RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
	v_invalid_data_count integer := 0;
begin
	select count(*)
	into v_invalid_data_count
	from organisationunit
	where uid like '%/%';

	return v_invalid_data_count;
end;
$$;

-- SELECT invalid_data_count() as count;
