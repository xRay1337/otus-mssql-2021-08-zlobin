-- ������ � ��������� ������������� �������. ��������������, ��� �� ���������
-- � "������" ��������� ����� ���������� 1 � 2 �������.

-- � �� ����������
USE SB_One;

-- ��������� ������� � �����������
INSERT INTO dbo.source (message_text)
VALUES
    (N'Far out in the uncharted backwaters of the unfashionable end of the western spiral arm of the Galaxy lies a small unregarded yellow sun.')
   ,(N'So long, and thanks for all the fish!..')
   ,(N'These creatures you call mice, you see, they are not quite as they appear. They are merely the protrusion into our dimension of vast hyperintelligent pandimensional beings. The whole business with the cheese and the squeaking is just a front.')
   ,(N'Mostly harmless')
   ,(N'The Ultimate Question of Life, the Universe, and Everything')
   ;

-- ��������� ���� ����� ������������ ���������
UPDATE dbo.source SET sent_at = SYSDATETIMEOFFSET() WHERE id = 1;

SELECT * FROM dbo.source;

-- ��������� ������ �������� ���������:
EXEC dbo.SendMessage @message_id = 1;  -- ��������� �� ����������, ���� ���������� �����;
EXEC dbo.SendMessage @message_id = 2;  -- ��������� �� ����������, �� ����������;
EXEC dbo.SendMessage @message_id = 3;  -- ��������� ����������.

SELECT * FROM dbo.source;

-- �� ������� ��������
USE SB_Two;
-- �������� ��������� � ���������� ���������.
EXEC dbo.RecieveMessage;

-- �� ������� ����������
USE SB_One;
-- �������� ��������� � ��������� ������.
EXEC dbo.ValidateReplyTicket

---- ������� �� �������� ��� ����� �������
USE SB_One;
SELECT cast(message_body as xml), * FROM DBOneSBQueue;

USE SB_Two;
SELECT cast(message_body as xml), * FROM DBTwoSBQueue;