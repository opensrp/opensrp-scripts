SELECT
  to_timestamp(client.date_created::BIGINT / 1000) at time zone 'Africa/Harare' AS "Date",
  CASE vaccine_type_id
  WHEN '1'
    THEN 'BCG'
  WHEN '2'
    THEN 'OPV'
  WHEN '3'
    THEN 'Penta'
  WHEN '4'
    THEN 'PCV'
  WHEN '5'
    THEN 'Rota'
  WHEN '6'
    THEN 'M/MR'
  ELSE 'other'
  END           AS                                 "Vaccine type",
  usr.person_id AS                                 "Provider ID",
  CASE WHEN usr.person_id IS NOT NULL
    THEN
      CASE
      WHEN prv.name IS NULL
        THEN CONCAT(pname.given_name, ' ', pname.family_name)
      ELSE prv.name
      END
  ELSE prv.name END
                AS                                 "Provider name",
  CASE WHEN tln.name SIMILAR TO 'so %|we %'
THEN substring(tln.name FROM 4)
ELSE tln.name
END AS "Location",
to_from AS "To/From"
FROM public.stock CLIENT
LEFT JOIN public.users usr ON LOWER(usr.username) = LOWER( CLIENT.providerid)
LEFT JOIN public.provider prv ON prv.person_id = usr.person_id
LEFT JOIN public.person_name pname ON pname.person_id = usr.person_id
LEFT JOIN public.team_member tm ON tm.person_id = usr.person_id AND tm.voided =0
LEFT JOIN public.member_location tl ON tl.team_member_id = tm.team_member_id
LEFT JOIN public.location tln ON tln.location_id = tl.location_id
WHERE usr.username <> 'biddemo'
GROUP BY CLIENT.date_created, vaccine_type_id, usr.person_id, prv.name, pname.given_name,
pname.family_name, CLIENT.transaction_type, tln.name, CLIENT.to_from
