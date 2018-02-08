USE dbo;
SELECT customer.cu_name
FROM customer
JOIN dbo.users ON users.us_name = customer.cu_name
JOIN dbo.supplier ON customer.cu_fax = supplier.su_fax
WHERE users.us_class like '%P%' AND
      supplier.su_phone like '%1%'
