select  to_timestamp (client.date_created::BIGINT / 1000) at time zone 'Africa/Harare' as "Date",



        CASE vaccine_type_id
        WHEN '1' THEN 'BCG'
        WHEN '2' THEN 'OPV'
        WHEN '3' THEN 'Penta'
        WHEN '4' THEN 'PCV'
        WHEN '5' THEN 'Rota'
        WHEN '6' THEN 'M/MR'
        ELSE 'other'
        END as "Vaccine type",

		transaction_type as "Transaction Type",
		value as "Value",

        usr.person_id as "Provider ID",


        CASE  WHEN usr.person_id IS NOT NULL THEN
          CASE
          WHEN prv.name IS NULL THEN CONCAT(pname.given_name,' ',pname.family_name)
          ELSE prv.name
          END
        ELSE  prv.name END
          as "Provider name",


  CASE WHEN tln.name SIMILAR TO 'so %|we %'
THEN substring(tln.name from 4)
ELSE tln.name
END as "Location",

to_from as "To/From"


FROM public.stock client


LEFT JOIN public.users usr ON LOWER(usr.username) = LOWER(client.providerid)
LEFT JOIN public.provider prv ON prv.person_id = usr.person_id
LEFT JOIN public.person_name pname ON pname.person_id = usr.person_id


LEFT JOIN public.team_member tm ON tm.person_id = usr.person_id and tm.voided =0
LEFT JOIN public.member_location tl ON tl.team_member_id = tm.team_member_id
LEFT JOIN public.location tln ON tln.location_id = tl.location_id
where usr.username <> 'biddemo'
GROUP BY client.date_created,vaccine_type_id,value,usr.person_id,prv.name,pname.given_name,
pname.family_name,client.transaction_type,tln.name,client.to_from

