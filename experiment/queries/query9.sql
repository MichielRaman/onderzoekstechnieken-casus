UPDATE item
SET item.it_price = (item.it_price * 0.1),
  item.it_qtity = 10,
  item.it_description = 'TV'
WHERE item.it_id > 10
  AND item.it_expirydate > '1-1-2007'
  AND item.it_expirydate < '1-1-2008'
