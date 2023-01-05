# queryTestInvertTable
Question :
Consider a table with an [Id] column as well as BIT columns named [A] to [E] and some initial values:
CREATE TABLE #TEST2 ([Id] INT, [A] BIT, [B] BIT, [C] BIT, [D] BIT, [E] BIT)
INSERT INTO #TEST2 ([Id], [A], [C], [E]) VALUES (1, 'true', 'false', 'true')
INSERT INTO #TEST2 ([Id], [A], [B], [C]) VALUES (2, 'true', 'true', 'true')
INSERT INTO #TEST2 ([Id], [C], [D], [E]) VALUES (1, 'false', 'false', 'true')
Create a procedure which will accept parameters ([Id] INT, [Column] CHAR (1)) and then invert the value in table #TEST2 for rows matched by [Id] and columns named [Column]. No change is made if the existing value is NULL.
