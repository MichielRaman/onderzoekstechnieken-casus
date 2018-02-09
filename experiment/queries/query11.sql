SELECT *
FROM dbo.category, dbo.item
WHERE dbo.item.it_ca_id = dbo.category.ca_id
