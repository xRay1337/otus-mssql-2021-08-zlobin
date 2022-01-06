

--�������� �������
CREATE PROCEDURE CRM.AddContact
(	@operatorId INT,
	@clientId INT,
	@resultId INT,
	@nextActionDT DATETIME2 = NULL
) AS
INSERT INTO CRM.Contacts(OperatorId, ClientId, ResultId, NextActionDT)
VALUES(@operatorId, @clientId, @resultId, @nextActionDT)

GO

--�������� �������
CREATE PROCEDURE CRM.AddClient
(
	@LastName		NVARCHAR(100),
	@FirstName		NVARCHAR(100),
	@MiddleName		NVARCHAR(100) = NULL,
	@Birthday		DATE = NULL,
	@Sex			CHAR(1) = NULL,
	@MobilNumber	VARCHAR(11),
	@AddMobilNumber VARCHAR(11),
	@Email			NVARCHAR(100),
	@RegionId		INT = NULL
) AS
INSERT INTO PersonalInfo.Clients(LastName, FirstName, MiddleName, Birthday, Sex, MobilNumber, AddMobilNumber, Email, RegionId)
VALUES(@LastName, @FirstName, @MiddleName, @Birthday, @Sex, @MobilNumber, @AddMobilNumber, @Email, @RegionId)


GO

--�������� ���������� �� �������
CREATE PROCEDURE CRM.UpdateClient
(
	@ClientId		INT,
	@LastName		NVARCHAR(100),
	@FirstName		NVARCHAR(100),
	@MiddleName		NVARCHAR(100) = NULL,
	@Birthday		DATE = NULL,
	@Sex			CHAR(1) = NULL,
	@MobilNumber	VARCHAR(11),
	@AddMobilNumber VARCHAR(11),
	@Email			NVARCHAR(100),
	@RegionId		INT = NULL
) AS
UPDATE PersonalInfo.Clients
SET	LastName = @LastName, 
	FirstName = @FirstName,
	MiddleName = @MiddleName,
	Birthday = @Birthday,
	Sex = @Sex,
	MobilNumber = @MobilNumber, 
	AddMobilNumber = @AddMobilNumber,
	Email = @Email,
	RegionId = @RegionId
WHERE ClientId = @ClientId


GO

--����� �� �������
CREATE VIEW CRM.ContactReport AS
SELECT	CON.ContactId AS [����� ������]
		,CAST(CON.ContactDT AS DATE) AS [���� ������]
		,REG.RegionName AS [������ ������]
		,RES.ContactResultName AS [��������� ������]
		,GRO.GroupName AS [������]
		,CONCAT(EMP.LastName, ' ', EMP.FirstName, ' ', EMP.MiddleName) AS [��� ���������]
		,1 AS [����������]
		,IIF(CON.ResultId IN (1, 2, 6), 1, 0) AS [������]
		,IIF(CON.ResultId = 1, 1, 0) AS [��������]
		,IIF(CON.ResultId = 2, 1, 0) AS [�����]
FROM CRM.Contacts				AS CON
JOIN CRM.Operators				AS OPE ON CON.OperatorId = OPE.OperatorId
JOIN PersonalInfo.Employees		AS EMP ON OPE.OperatorEmployeeId = EMP.EmployeeId
JOIN OrgStructure.Groups		AS GRO ON OPE.OperatorGroupId = GRO.GroupId
JOIN PersonalInfo.Clients		AS CLI ON CON.ClientId = CLI.ClientId
JOIN Dimensions.Regions			AS REG ON CLI.RegionId = REG.RegionId
JOIN CRM.ContactResults			AS RES ON CON.ResultId = RES.ContactResultId
WHERE CON.ResultId <> 5
