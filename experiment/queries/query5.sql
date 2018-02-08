USE dbo;
SELECT SUM(invoice.in_total),
  AVG(invoice.in_totalafterdiscount),
  MAX(invoice.in_total),
  COUNT(customer.cu_id),
  SUM(invoicedetail.ind_qty)
FROM customer, invoice, invoicedetail
WHERE customer.cu_id = invoice.in_cu_id AND
      invoice.in_id = invoicedetail.ind_in_id
GROUP BY invoice.in_id ;
