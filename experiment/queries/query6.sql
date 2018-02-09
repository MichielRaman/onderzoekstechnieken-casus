SELECT SUM(dbo.invoice.in_total)
FROM dbo.invoice
JOIN dbo.customer ON customer.cu_id = invoice.in_cu_id
GROUP BY dbo.customer.cu_id
HAVING COUNT(invoice.in_id) > 0 AND
       SUM(invoice.in_total) < AVG(invoice.in_totalafterdiscount)
ORDER BY SUM(dbo.invoice.in_total);
