USE WideWorldImporters

GO

/*
1. �������� ������� ������������ ������� � ���������� ������ �������.
*/

CREATE FUNCTION [Sales].[GetCustomerIdWithHighestPurchaseAmount]()
RETURNS int
AS
BEGIN
	RETURN
	(
		SELECT [CustomerID]
		FROM
		(
			SELECT TOP 1
					[CustomerID]
					,SUM([Quantity] * [UnitPrice]) AS [SalesAmount]
			FROM [Sales].[Orders] AS [O]
			JOIN [Sales].[OrderLines] AS [OL] ON [O].[OrderID] = [OL].[OrderID]
			GROUP BY [CustomerID]
			ORDER BY [SalesAmount] DESC
		) AS [Subquery]
	)
END

--SELECT [Sales].[GetCustomerIdWithHighestPurchaseAmount]() --149

GO

/*
2. �������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
������������ ������� : Sales.Customers Sales.Invoices Sales.InvoiceLines
*/

CREATE PROCEDURE [Sales].[GetCustomerSalesAmount] @customerId int
WITH EXECUTE AS CALLER  
AS
SET NOCOUNT ON									--��� ������ ���������� �����
SET TRANSACTION ISOLATION LEVEL READ COMMITTED	--������� �� ���������, �.�. ���� ������ ������ ������ 1 ���
	
SELECT SUM([Quantity] * [UnitPrice]) AS [SalesAmount]
FROM [Sales].[Invoices] AS [I]
JOIN [Sales].[OrderLines] AS [OL] ON [I].[OrderID] = [OL].[OrderID]
WHERE [CustomerID] = @customerId
GROUP BY [CustomerID]

--EXEC [Sales].[GetCustomerSalesAmount] @customerId = 149

GO

/*
3. ������� ���������� ������� � �������� ���������, �������� ������������������.
*/


CREATE FUNCTION [Sales].[GetCustomerSalesAmountById](@customerId int)
RETURNS int
AS
BEGIN
	RETURN
	(
		SELECT SUM([Quantity] * [UnitPrice]) AS [SalesAmount]
		FROM [Sales].[Invoices] AS [I]
		JOIN [Sales].[OrderLines] AS [OL] ON [I].[OrderID] = [OL].[OrderID]
		WHERE [CustomerID] = @customerId
		GROUP BY [CustomerID]
	)
END

GO

--/*

SET STATISTICS IO, TIME ON

------------------------------------------------------------

--��������� ��������� ���� ���� ������� �� ��� id:
EXEC [Sales].[GetCustomerSalesAmount] @customerId = 149

--��������� ������� ������� ���������:
	--���������� ������ 752
	--����������� ����� = 490 ��.
--��������� 5�� ������� ���������:
	--���������� ������ 396
	--����������� ����� = 4 ��.
--���������: 0,465603
------------------------------------------------------------

--������� ��������� ���� ���� ������� �� ��� id:
SELECT [Sales].[GetCustomerSalesAmountById](149)

--��������� ������� ������� �������:
	--����� �� = 15 ��, ����������� ����� = 12 ��.
--��������� 5�� ������� �������:
	--����� �� = 0 ��, ����������� ����� = 9 ��.
--���������: 0,0000013

--�����, ��� ������� ������� �� 5 ��������.
--������ ���, ���� ��� ��� ���������, ������ ��� ���������, �� ������ ������� ����� ����������� �������.

--*/

GO

/*
4. �������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����.
*/

CREATE FUNCTION [Sales].[GetCustomerTopPurchasedItemsById](@customerId int, @itemsCount int)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP (@itemsCount)
			[SI].[StockItemName]
			,SUM([OL].[Quantity]) AS [PurchasedItemsCount]
	FROM [Warehouse].[StockItems]	AS [SI]
	JOIN [Sales].[OrderLines]		AS [OL] ON [SI].[StockItemID] = [OL].[StockItemID]
	JOIN [Sales].[Orders]			AS [SO] ON [OL].[OrderID] = [SO].[OrderID]
	WHERE [SO].[CustomerID] = @customerId
	GROUP BY [SO].[CustomerID], [SI].[StockItemName]
	ORDER BY [PurchasedItemsCount] DESC
)

GO   

DECLARE @itemsCount int = 3 --�������� TOP-3 ������ �� ���������� ������� ��� ������� �������

SELECT	[CustomerID]
		,[CustomerName]
		,[PurchasedItems].*
FROM [WideWorldImporters].[Sales].[Customers]
CROSS APPLY [Sales].[GetCustomerTopPurchasedItemsById]([CustomerID], @itemsCount) AS [PurchasedItems]
ORDER BY [CustomerID], [PurchasedItems].[PurchasedItemsCount] DESC

