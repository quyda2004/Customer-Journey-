DROP TABLE TMP_DQ_VALUE_COUNTS
SELECT CAST('' AS NVARCHAR(128)) TABLE_NAME, CAST('' AS NVARCHAR(128)) COLUMN_NAME, CAST(0 AS NUMERIC(128)) ROWS_COUNT, CAST('' AS NVARCHAR(128)) MAX_LEN
INTO TMP_DQ_VALUE_COUNTS

-- STEP 1 - Declare variables
DECLARE @sql NVARCHAR(MAX);
DECLARE @tableName NVARCHAR(128);
DECLARE @columnName NVARCHAR(128);
DECLARE @outputTable NVARCHAR(128) = 'TMP_DQ_VALUE_COUNTS';

-- STEP 2 - Declare cursor
DECLARE tableCursor CURSOR FOR
SELECT TABLE_NAME, COLUMN_NAME
FROM [INFORMATION_SCHEMA].[COLUMNS]
WHERE TABLE_NAME <> 'sysdiagrams'

-- STEP 3 - Open cursor
OPEN tableCursor;
FETCH NEXT FROM tableCursor INTO @tableName, @columnName;

-- STEP 4 - Fetch
-- SQL Server provides the @@FETCHSTATUS function that returns the status of the last cursor FETCH statement executed against the cursor;
-- If @@FETCHSTATUS returns 0, meaning the FETCH statement was successful. You can use the WHILE statement to fetch all rows from the cursor as shown in the following code:
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'
	INSERT INTO '+  QUOTENAME(@outputTable) +'
    SELECT 
        ''' + @tableName + N''' AS TableName, 
        ''' + @columnName + N''' AS ColumnName, 
        COUNT(*) AS NonNullRowCount,
		MAX(LEN('+ @columnName +')) AS MAX_LEN 
		
    FROM 
        ' + QUOTENAME(@tableName) + N'
    WHERE 
        ' + QUOTENAME(@columnName) + N' IS NOT NULL;';

    EXEC sp_executesql @sql; -- Stored Procedure

    -- Accessing the cursor values
    PRINT 'Table Name: ' + @tableName;
    PRINT 'Column Name: ' + @columnName;

    FETCH NEXT FROM tableCursor INTO @tableName, @columnName;
END;


-- STEP 5 - Close Curson
CLOSE tableCursor;

-- STEP 6 - Deallocate Curson
DEALLOCATE tableCursor;

SELECT *
FROM TMP_DQ_VALUE_COUNTS

DELETE FROM TMP_DQ_VALUE_COUNTS
WHERE TABLE_NAME = ''

--
-- Precision: Precision refers to the total number of digits that can be stored in a numeric data type.
-- Precision Radix: Precision radix, also known as the base or radix, specifies the number of unique digits or symbols that can be used to represent numeric values. 
					-- In most cases, the precision radix is 10, which means that decimal digits (0-9) are used. However, some numeric data types, 
					-- such as binary or hexadecimal, may have a precision radix of 2 or 16, respectively.
-- Scale: Scale represents the number of digits that can be stored to the right of the decimal point. 
-- It indicates the maximum number of decimal places that can be represented. For example, a numeric data type with a scale of 2 can store values with up to 2 decimal places.
SELECT TABLE_CATALOG, TABLE_SCHEMA, A.TABLE_NAME, A.COLUMN_NAME, IS_NULLABLE, DATA_TYPE, ISNULL(CHARACTER_MAXIMUM_LENGTH,NUMERIC_PRECISION) MAX_LENGTH, B.ROWS_COUNT, B.MAX_LEN
FROM [INFORMATION_SCHEMA].[COLUMNS] A
LEFT JOIN TMP_DQ_VALUE_COUNTS B ON A.TABLE_NAME = B.TABLE_NAME AND A.COLUMN_NAME = B.COLUMN_NAME
WHERE A.TABLE_NAME <> 'sysdiagrams'
