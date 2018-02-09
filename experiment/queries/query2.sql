SELECT * FROM dbo.invoice
WHERE invoice.in_id > 50 AND invoice.in_date > '1-1-2006' AND invoice.in_date < '1-1-2007'
AND invoice.in_description LIKE '%re%'
AND (invoice.in_total <> 100 OR NOT invoice.in_cu_id >= 5 )
AND (invoice.in_id BETWEEN 1 AND 10000 OR invoice.in_id > 49+1)
AND invoice.in_total+33 <> 5
