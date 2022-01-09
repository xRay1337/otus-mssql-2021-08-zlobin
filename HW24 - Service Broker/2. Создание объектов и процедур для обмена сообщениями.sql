-- � ���� ������� ������������ �������� ����������� ��� ������ ����������� �������� � ��������:
--     * SB_One.dbo.source -- ������� � �������, �� ������� ����������� ��������� ��� ��������;
--     * SB_Two.dbo.target -- ������� ��� ����� ������;
--     * SB_One.dbo.SendMessage -- ������ ������ � ���������� ��������;
--     * SB_Two.dbo.RecieveMessage -- �������� ��������� �� ������� � ���������� �������������;
--     * SB_One.dbo.ValidateReplyTicket -- �������� ������������� � ��������� ������.

USE SB_One;

DROP TABLE IF EXISTS dbo.source;
CREATE TABLE dbo.source
(
    id              INT             IDENTITY(1,2)   NOT NULL    PRIMARY KEY
   ,created_at      DATETIMEOFFSET                  NOT NULL    DEFAULT SYSDATETIMEOFFSET()
   ,sent_at         DATETIMEOFFSET                      NULL
   ,message_text    NVARCHAR(MAX)                   NOT NULL
);
GO

CREATE PROCEDURE dbo.SendMessage
    @message_id int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @init_dlg_handle uniqueidentifier
       ,@request_message nvarchar(max);

    -- �������� �� �������������
    IF NOT EXISTS (select 1 FROM dbo.source WHERE id = @message_id)
    BEGIN
        PRINT N'��������� � ID ' + CAST(@message_id AS nvarchar(9)) + N' �� ����������!'
        RETURN 1
    END

    -- �������� ��������� �� �������� �����
    IF (SELECT sent_at FROM dbo.source WHERE id = @message_id) IS NOT NULL
    BEGIN
        PRINT N'��������� � ID ' + CAST(@message_id AS nvarchar(9)) + N' ��� ����������!'
        RETURN 2
    END;

    BEGIN TRAN

    SELECT @request_message = (
        SELECT id, message_text
        FROM dbo.source AS msg
        WHERE id = @message_id
        FOR XML AUTO, root('request')
    )

    BEGIN DIALOG @init_dlg_handle
    FROM SERVICE [//RBOne/SB/Service]
    TO SERVICE   '//RBTwo/SB/Service'
    ON CONTRACT  [//DBOne/SB/Contract]
    WITH ENCRYPTION = OFF;

    SEND ON CONVERSATION @init_dlg_handle
    MESSAGE TYPE [//DBOne/SB/Request]
    (@request_message);

    UPDATE dbo.source
    SET sent_at = SYSDATETIMEOFFSET()
    WHERE id = @message_id;

    COMMIT TRAN

END;
GO

CREATE PROCEDURE dbo.ValidateReplyTicket
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @reply_dlg_handle uniqueidentifier
       ,@reply_message    nvarchar(max);

    BEGIN TRAN;
        RECEIVE TOP(1)
            @reply_dlg_handle = conversation_handle
           ,@reply_message = message_body
        FROM dbo.DBOneSBQueue;

        SELECT @reply_message;

        END CONVERSATION @reply_dlg_handle;
    COMMIT TRAN
END;
GO

---------------------------------------
USE SB_Two;

CREATE TABLE dbo.destination (
    id              int             IDENTITY(1,2)   NOT NULL    PRIMARY KEY
   ,source_id       int                             NOT NULL
   ,recieved_at     datetimeoffset                  NOT NULL
   ,modified_at     datetimeoffset                  NOT NULL
   ,confirmed_at    datetimeoffset                      NULL
   ,message_text    nvarchar(max)                   NOT NULL
);
GO


CREATE PROCEDURE dbo.RecieveMessage
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @target_dlg_handler uniqueidentifier
       ,@message            nvarchar(max)
       ,@message_type       sysname
       ,@reply_message      nvarchar(max)
       ,@reply_message_name sysname
       ,@source_id          int
       ,@message_text       nvarchar(max)
       ,@operation_type     nvarchar(1)
       ,@xml                xml;

    BEGIN TRAN

        -- �������� ��������� �� ������
        SELECT TOP(1)
            @target_dlg_handler = Conversation_Handle
           ,@message = message_body
           ,@message_type = message_type_name
        FROM DBTwoSBQueue;

        -- �������� �� ������������� ���������
        IF @@ROWCOUNT = 0
        BEGIN
            PRINT N'� ������� ��� ���������';
            ROLLBACK TRAN;
            RETURN 3;
        END;

        -- ��������� ��������� �� ������������
        SET @xml = cast(@message AS xml);

        SELECT
            @source_id = request.body.value('@id', 'INT')
           ,@message_text = request.body.value('@message_text', 'nvarchar(max)')
        FROM @xml.nodes('/request/msg') AS request(body);

        -- ���� ���������� ����� ���������, �� �������� ����� � ���� ���������...
        IF EXISTS (SELECT 1 FROM dbo.destination WHERE source_id = @source_id)
        BEGIN
            SET @operation_type = N'U';

            UPDATE dbo.destination
            SET
                message_text = @message_text
               ,modified_at = SYSDATETIMEOFFSET()
            WHERE source_id = @source_id;
        END
        -- ...����� -- �������� � ������� ����������.
        ELSE
        BEGIN
            SET @operation_type = N'I';

            INSERT INTO dbo.destination (source_id, recieved_at, modified_at, message_text)
            SELECT @source_id, SYSDATETIMEOFFSET(), SYSDATETIMEOFFSET(), @message_text;
        END

        -- ��������� � �������� ������������� ���������
        IF @message_type = N'//DBOne/SB/Request'
        BEGIN
            SET @reply_message = N'<reply>Ticket for message id="'+ CAST(@source_id AS varchar) + '", operation_type="' + @operation_type + '"</reply>';

            SEND ON CONVERSATION @target_dlg_handler
            MESSAGE TYPE [//DBOne/SB/Reply]
            (@reply_message);
            END CONVERSATION @target_dlg_handler;
        END

    COMMIT TRAN
END;
GO