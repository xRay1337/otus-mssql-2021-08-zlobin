/*�����:
	����������� ���������� ������ ������� Invoices � 7 ���(��� ������� ������� �������), � ����� ������ ���������� � 9 ���
	�� ���� ������ 1�� ���������� �� ��������� ������� ����� ������� ������������������(� CTE ������� ����)
	������ 2�� ���������� ������ ����� � Warehouse.StockItems
	������ �������� ������(JOIN CustomerTransactions � JOIN StockItemTransactions) � ����������(ORDER BY ord.CustomerID, det.StockItemID)
	������� "DATEDIFF(DAY, Inv.InvoiceDate, ord.OrderDate) = 0" �������� "Inv.InvoiceDate = ord.OrderDate" - ��������� ������ ����������
	COUNT(ord.OrderID) ������ �� COUNT(*) - ����� � ���� ���� ��������� �������, �.�. �� ��������� �������� �� NULL
	������� ���������� ���������������
*/

SET STATISTICS IO, TIME ON

DROP TABLE IF EXISTS #CustomersId


SELECT CustomerID
INTO #CustomersId
FROM Sales.Orders		AS O
JOIN Sales.OrderLines	AS OL ON O.OrderID = OL.OrderID
GROUP BY CustomerID
HAVING SUM(OL.UnitPrice * OL.Quantity) > 250000


SELECT	O.CustomerID,
		OL.StockItemID,
		SUM(OL.UnitPrice)	AS UnitPrice,
		SUM(OL.Quantity)	AS Quantity,
		COUNT(*)			AS OrdersCount
FROM #CustomersId						AS CI
JOIN Sales.Orders						AS O	ON CI.CustomerID = O.CustomerID
JOIN Sales.OrderLines					AS OL	ON O.OrderID = OL.OrderID
JOIN Sales.Invoices						AS I	ON O.OrderID = I.OrderID
JOIN Warehouse.StockItems				AS SI	ON OL.StockItemID = SI.StockItemID
WHERE O.OrderDate = I.InvoiceDate
	AND O.CustomerID <> I.BillToCustomerID
	AND SI.SupplierId = 12
GROUP BY O.CustomerID, OL.StockItemID

--3 619

/*����

������� "Orders".					����� ���������� 2, ���������� ������ 883, ���������� ������ 4.
������� "OrderLines".				����� ���������� 4, ���������� ������ 0, ���������� ������ 0.
������� "Invoices".					����� ���������� 1, ���������� ������ 76422, ���������� ������ 2.
������� "StockItems".				����� ���������� 1, ���������� ������ 2, ���������� ������ 1.
������� "CustomerTransactions".		����� ���������� 5, ���������� ������ 261, ���������� ������ 4.
������� "StockItemTransactions".	����� ���������� 1, ���������� ������ 0, ���������� ������ 0.

����� �� = 937 ��, ����������� ����� = 4502 ��.

*/

/*�����

������� "Orders".								����� ���������� 1, ���������� ������ 191, ���������� ������ 0.
������� "OrderLines".							����� ���������� 2, ���������� ������ 0, ���������� ������ 0.

������� "#CustomerIdWithTotalSalesOverValue".	����� ���������� 5, ���������� ������ 1, ���������� ������ 0.
������� "Orders".								����� ���������� 5, ���������� ������ 725, ���������� ������ 0.
������� "OrderLines".							����� ���������� 8, ���������� ������ 0, ���������� ������ 0.
������� "Invoices".								����� ���������� 5, ���������� ������ 11994, ���������� ������ 0.
������� "StockItems".							����� ���������� 1, ���������� ������ 2, ���������� ������ 0.

����� �� = 109 ��, ����������� ����� = 278 ��.

*/