/*�����:
	������� ��������� ����������� ������ ������� Invoices � 7 ���(��� ������� ������� �������), � ����� ������ ���������� � 3 ����
	�� ���� ������ ����������� �� ��������� ������� � ����������� ����������� ����� ������� ������������������
	���������������� �������� ������ � ����������
	������� "DATEDIFF(DAY, Inv.InvoiceDate, ord.OrderDate) = 0" �������� "Inv.InvoiceDate = ord.OrderDate" - ��������� ������ ����������
	COUNT(ord.OrderID) ������ �� COUNT(*) - ����� � ���� ���� ��������� �������
	���������� ���������������, ���������� �������� ������ ����� ���������������� � �������
*/

SET STATISTICS IO, TIME ON

DROP TABLE IF EXISTS #totalSales
DROP TABLE IF EXISTS #StockItemsIdBySupplierId


SELECT	CustomerID,
		SUM(Total.UnitPrice * Total.Quantity) AS Total
INTO #TotalSales
FROM Sales.OrderLines	AS Total
JOIN Sales.Orders		AS OrdTotal ON OrdTotal.OrderID = Total.OrderID
GROUP BY CustomerID
HAVING SUM(Total.UnitPrice * Total.Quantity) > 250000

CREATE CLUSTERED INDEX IDX_CustomerID ON #TotalSales(CustomerID) --����� ������ � �������� �������, �.�. � ��������� � ���������� ����� ����� ������ ���������, ��� ��������� �������, ������� �������� ����, � ����� ��������


SELECT DISTINCT StockItemID
INTO #StockItemsIdBySupplierId
FROM Warehouse.StockItems
WHERE SupplierId = 12

CREATE CLUSTERED INDEX IDX_StockItemID ON #StockItemsIdBySupplierId(StockItemID) --����� ������ � �������� �������, �.�. � ��������� ���������� ����� ����� ������ ���������, ��� ��������� �������, ������� �������� ����, � ����� ��������


SELECT	ord.CustomerID,
		det.StockItemID,
		SUM(det.UnitPrice),
		SUM(det.Quantity),
		COUNT(*) --ord.OrderID NOT NULL, ������� ����� ������� *, � �� ��������� ������ ��� ���� �� NULL
FROM #TotalSales						AS ordTotal
JOIN Sales.Orders						AS ord		 ON ordTotal.CustomerID = ord.CustomerID
JOIN Sales.OrderLines					AS det		 ON det.OrderID = ord.OrderID
JOIN #StockItemsIdBySupplierId			AS It		 ON It.StockItemID = det.StockItemID
JOIN Sales.Invoices						AS Inv		 ON Inv.OrderID = ord.OrderID
/*�������������� ������, ���� �����, �� �����������������
JOIN Sales.CustomerTransactions			AS Trans	 ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions	AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
*/
WHERE Inv.InvoiceDate = ord.OrderDate --������ DATEDIFF(DAY, Inv.InvoiceDate, ord.OrderDate) = 0. ������ ����������, ���� ������ ���������
	AND Inv.BillToCustomerID <> ord.CustomerID
GROUP BY ord.CustomerID, det.StockItemID
--ORDER BY ord.CustomerID, det.StockItemID --�� ����, ����� �� ����������, ���� �����, �� �����������������

--3 619

/*����

������� "StockItemTransactions".	����� ���������� 1, ���������� ������ 0, ���������� ������ 0.
������� "OrderLines".				����� ���������� 4, ���������� ������ 0, ���������� ������ 0.
������� "CustomerTransactions".		����� ���������� 5, ���������� ������ 261, ���������� ������ 4.
������� "Orders".					����� ���������� 2, ���������� ������ 883, ���������� ������ 4.
������� "Invoices".					����� ���������� 1, ���������� ������ 76422, ���������� ������ 2.
������� "StockItems".				����� ���������� 1, ���������� ������ 2, ���������� ������ 1.

����� �� = 937 ��, ����������� ����� = 4502 ��.

*/

/*�����

������� "OrderLines".					����� ���������� 2, ���������� ������ 0, ���������� ������ 0.
������� "Orders".						����� ���������� 1, ���������� ������ 191, ���������� ������ 1.

������� "StockItems".					����� ���������� 1, ���������� ������ 2, ���������� ������ 1.

������� "#StockItemsIdBySupplierId".	����� ���������� 1, ���������� ������ 2, ���������� ������ 0.
������� "OrderLines".					����� ���������� 8, ���������� ������ 0, ���������� ������ 0.
������� "Orders".						����� ���������� 5, ���������� ������ 725, ���������� ������ 3.
������� "#totalSales".					����� ���������� 5, ���������� ������ 7, ���������� ������ 0.
������� "Invoices".						����� ���������� 5, ���������� ������ 11580, ���������� ������ 3.

����� �� = 344 ��, ����������� ����� = 3216 ��.

*/