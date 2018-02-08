USE dbo;
SELECT customer.cu_id, customer.cu_name, customer.cu_telephone, customer.cu_fax , customer.cu_email
FROM customer
ORDER BY customer.cu_id, customer.cu_name DESC, customer.cu_telephone DESC, customer.cu_fax, customer.cu_email DESC;
