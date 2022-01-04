USE Organization

GO

--�������� ������� ���������������
CREATE PARTITION FUNCTION [pfYears](DATETIME2) AS RANGE RIGHT FOR VALUES('20220101');

GO

--�������� ����� ��������������� �� ���� ������� [pfYears]
CREATE PARTITION SCHEME [psYears] AS PARTITION [pfYears] TO ([PRIMARY], [PRIMARY])

GO

--�������� ����������������� ������� �� [ContactId] �� ������ ��������������� [psYears]
CREATE CLUSTERED INDEX [IdxContactId] on [CRM].[Contacts]([ContactId]) ON [psYears]([ContactDT])

GO

SELECT DISTINCT t.name
FROM sys.partitions p
JOIN sys.tables t ON p.object_id = t.object_id
WHERE p.partition_number <> 1

GO

SELECT  $PARTITION.pfYears(ContactDT) AS PartitionNum
		,COUNT(*)			AS [Count]
		,MIN(ContactDT)	AS [MaxValue]
		,MAX(ContactDT)	AS [MinValue]
FROM [CRM].[Contacts]
GROUP BY $PARTITION.pfYears(ContactDT) 
ORDER BY PartitionNum ;  