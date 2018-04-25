 UPDATE couchdb SET doc=jsonb_set( jsonb_set(doc,'{_rev}','"1-version"',FALSE ),
                                        '{_id}',concat('"',md5(doc->>'_id'),'"')::jsonb,FALSE );

/*DO $$
  DECLARE documents_cursor CURSOR FOR
  SELECT * from couchdb;
  rec RECORD;
BEGIN
    OPEN documents_cursor;
    LOOP
      FETCH documents_cursor into rec;
      EXIT WHEN NOT FOUND;

      UPDATE couchdb SET doc=jsonb_set( jsonb_set(doc,'{_rev}','"1-version"',FALSE ),
                                        '{_id}',concat('"',md5(doc->>'_id'),'"')::jsonb,FALSE )
      WHERE CURRENT OF documents_cursor;

    END LOOP;
    CLOSE documents_cursor;
END;
$$*/
