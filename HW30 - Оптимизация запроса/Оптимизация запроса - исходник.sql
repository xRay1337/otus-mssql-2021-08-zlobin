set statistics io, time on

Select	ord.CustomerID,
		det.StockItemID,
		SUM(det.UnitPrice),
		SUM(det.Quantity),
		COUNT(ord.OrderID)
FROM Sales.Orders						AS ord
JOIN Sales.OrderLines					AS det		 ON det.OrderID = ord.OrderID
JOIN Sales.Invoices						AS Inv		 ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions			AS Trans	 ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions	AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(DAY, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID


/*����
3 619
������� "StockItemTransactions". ����� ���������� 1, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 66, lob ���������� ������ 1, lob ����������� ������ 130.
������� "StockItemTransactions". ������� ��������� 1, ��������� 0.
������� "OrderLines". ����� ���������� 4, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 518, lob ���������� ������ 5, lob ����������� ������ 795.
������� "OrderLines". ������� ��������� 2, ��������� 0.
������� "Worktable". ����� ���������� 0, ���������� ������ 0, ���������� ������ 0, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "CustomerTransactions". ����� ���������� 5, ���������� ������ 261, ���������� ������ 4, ����������� ������ 253, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Orders". ����� ���������� 2, ���������� ������ 883, ���������� ������ 4, ����������� ������ 849, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "Invoices". ����� ���������� 1, ���������� ������ 76422, ���������� ������ 2, ����������� ������ 11606, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.
������� "StockItems". ����� ���������� 1, ���������� ������ 2, ���������� ������ 1, ����������� ������ 0, lob ���������� ������ 0, lob ���������� ������ 0, lob ����������� ������ 0.

����� �� = 937 ��
*/