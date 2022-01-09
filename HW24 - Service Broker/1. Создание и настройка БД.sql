-- � ���� ������� ��������� � ������������� �� ��� ������������� ServiceBroker'�.
--     * SB_One -- ��, ������������ �������;
--     * SB_Two -- ��, ����������� � ������������� ���������.

USE master;

---- �� ���������� �������.
-- 01. ������ ��.
DROP DATABASE IF EXISTS SB_One;
GO

CREATE DATABASE SB_One;
GO

-- 02. �������� ServiceBroker.
IF (SELECT is_broker_enabled FROM sys.databases WHERE name = 'SB_One') = 0
    ALTER DATABASE SB_One SET ENABLE_BROKER;
GO

-- 03. ����������� ������� ������� � ��.
IF (SELECT is_trustworthy_on FROM sys.databases WHERE name = 'SB_One') = 0
    ALTER DATABASE SB_One SET TRUSTWORTHY ON;
GO

-- 04. ����� sa.
ALTER AUTHORIZATION
   ON DATABASE::SB_One TO [sa];
GO

-- 05. ������ ���� ���������.
USE SB_One;

CREATE MESSAGE TYPE [//DBOne/SB/Request] VALIDATION = WELL_FORMED_XML;
CREATE MESSAGE TYPE [//DBOne/SB/Reply]   VALIDATION = WELL_FORMED_XML;
GO

-- 06. ������ ��������.
CREATE CONTRACT [//DBOne/SB/Contract]
(
	[//DBOne/SB/Request] SENT BY INITIATOR,
	[//DBOne/SB/Reply]   SENT BY TARGET
);
GO

-- 07. ������ ������� ��� ����� ���������. ����� ����� ��� "���������"
-- � ����� ������������� ���������.
CREATE QUEUE DBOneSBQueue;

-- 08. ������ ������ ����� ���������
CREATE SERVICE [//RBOne/SB/Service] ON QUEUE DBOneSBQueue;
GO


---- �� ���������� �������
USE master;

-- 09. ������ ��
DROP DATABASE IF EXISTS SB_Two;
GO

CREATE DATABASE SB_Two;
GO

-- 10. �������� ServiceBroker.
IF (SELECT is_broker_enabled FROM sys.databases WHERE name = 'SB_Two') = 0
    ALTER DATABASE SB_Two SET ENABLE_BROKER;
GO

-- 11. ����������� ������� ������� � ��.
IF (SELECT is_trustworthy_on FROM sys.databases WHERE name = 'SB_Two') = 0
    ALTER DATABASE SB_Two SET TRUSTWORTHY ON;
GO

-- 12. ����� ����� sa.
ALTER AUTHORIZATION
   ON DATABASE::SB_Two TO [sa];
GO

-- 13. ������ ���� ���������. ������ ��������� � SB_One.
USE SB_Two;

CREATE MESSAGE TYPE [//DBOne/SB/Request] VALIDATION = WELL_FORMED_XML;
CREATE MESSAGE TYPE [//DBOne/SB/Reply]   VALIDATION = WELL_FORMED_XML;
GO

-- 14. ������ ��������.  ������ ��������� � SB_One.
CREATE CONTRACT [//DBOne/SB/Contract]
(
	[//DBOne/SB/Request] SENT BY INITIATOR,
	[//DBOne/SB/Reply]   SENT BY TARGET
);
GO

-- 15. ������ ������� ��� ����� ���������.
CREATE QUEUE DBTwoSBQueue;

-- 16. ������ ������ ����� ���������. ������ ���������� ��������� ������� � ��������.
CREATE SERVICE [//RBTwo/SB/Service] ON QUEUE DBTwoSBQueue ([//DBOne/SB/Contract]);
GO

-- 99. ��������� ��� ���������.