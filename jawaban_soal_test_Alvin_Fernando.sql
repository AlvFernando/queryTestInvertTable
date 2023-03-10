USE [TEST_DB]
GO
/****** Object:  StoredProcedure [dbo].[sp_invertTable]   Script Date: 05/01/2023 09:50:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alvin Fernando>
-- Create date: <2022-01-05>
-- Description:	<Invert Table #TEST@ by input id and column>
-- =============================================
CREATE PROCEDURE [dbo].[sp_invertTable] 
	-- Add the parameters for the stored procedure here
	@id as INTEGER,
	@column CHARACTER(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here

	DECLARE @result as NVARCHAR(600)
	DECLARE @customId as NVARCHAR(30)
	DECLARE @customColumn as NVARCHAR(3)

	--get custom id
	SELECT @customId = SUBSTRING(
	(
		SELECT ',' + '['+convert(VARCHAR,a.customId)+']' AS 'data()'
		FROM (
			SELECT 
				id,CAST(id as VARCHAR)+' '+ CAST(rnum as varchar) as customId
			FROM (
				SELECT *, ROW_NUMBER() OVER(ORDER BY id) as [rnum] FROM #TEST2 
			)b
			WHERE id = @id
		)a
		ORDER BY a.id FOR XML PATH('')
	),2,9999)

	--get custom row
	SELECT @customColumn = '['+@column+']'

	--invert result
	IF(@customId IS NOT NULL)
	BEGIN
	SET @result = 'SELECT *
	FROM (
		SELECT	id, col, value
		FROM (
			SELECT 
				CAST(id as VARCHAR)+'' ''+ CAST(rnum as varchar) as id,
				CAST([A] AS tinyint) AS A,
				CAST([B] AS tinyint) AS B,
				CAST([C] AS tinyint) AS C,
				CAST([D] AS tinyint) AS D,
				CAST([E] AS tinyint) AS E
			FROM (
				SELECT *, ROW_NUMBER() OVER(ORDER BY id) as [rnum] FROM #TEST2
			)a
		)source
		UNPIVOT(
			value for col in ('+@customColumn+')
		)unpiv
	)src
	PIVOT(
		SUM(value)
		for id in ('+@customId+')
	)piv'
	BEGIN TRY
		EXEC SP_EXECUTESQL @result
	END TRY
	BEGIN CATCH
		SELECT 'NO DATA' as [message]
	END CATCH
	END
	ELSE
	BEGIN
		SELECT 'ID NOT FOUND' as [message]
	END
END

CREATE TABLE #TEST2 ([Id] INT, [A] BIT, [B] BIT, [C] BIT, [D] BIT, [E] BIT)
INSERT INTO #TEST2 ([Id], [A], [C], [E]) VALUES (1, 'true', 'false', 'true')
INSERT INTO #TEST2 ([Id], [A], [B], [C]) VALUES (2, 'true', 'true', 'true')
INSERT INTO #TEST2 ([Id], [C], [D], [E]) VALUES (1, 'false', 'false', 'true')

EXEC [sp_invertTable] @id = 2,@column = 'D'

--CATATAN
--Di karenakan pada saat invert table terdapat id yang sama, maka saya membuatkan custom id dengan melakukan append
--antara id dan juga row_number dengan tujuan row id bisa dijadikan kolom
