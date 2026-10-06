-- ============================================================
-- 6.2 NULL CHECK ENGINE - TEST
-- ============================================================

DECLARE @SchemaName VARCHAR(128);
DECLARE @TableName VARCHAR(128);
DECLARE @ColumnName VARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);

SELECT TOP 1
    @SchemaName = t.SchemaName,
    @TableName = t.TableName,
    @ColumnName = t.ColumnName
FROM dbo.DQRule AS r
INNER JOIN dbo.DQRuleTarget AS t
    ON r.RuleID = t.RuleID
WHERE
    r.RuleCategory = 'COMPLETENESS'
    AND r.Enabled = 1
    AND t.Enabled = 1;


SET @SQL =
    'SELECT COUNT(*) AS NullCount
     FROM ' + QUOTENAME(@SchemaName) + '.' +
     QUOTENAME(@TableName) +
     ' WHERE ' + QUOTENAME(@ColumnName) + ' IS NULL;';


PRINT @SQL;

EXEC sp_executesql @SQL;

-- ============================================================
-- 6.2 NULL CHECK ENGINE
-- ============================================================

DECLARE
    @RuleID VARCHAR(20),
    @RuleTargetID VARCHAR(20),
    @SchemaName VARCHAR(128),
    @TableName VARCHAR(128),
    @ColumnName VARCHAR(128),
    @RuleName VARCHAR(100),
    @RuleCategory VARCHAR(50),
    @Severity VARCHAR(20),
    @SQL NVARCHAR(MAX);

DECLARE
    @TotalRows INT,
    @IssueCount INT,
    @Status VARCHAR(20),
    @Details VARCHAR(1000);

DECLARE DQ_NULL_CURSOR CURSOR FOR

SELECT
    r.RuleID,
    t.RuleTargetID,
    t.SchemaName,
    t.TableName,
    t.ColumnName,
    r.RuleName,
    r.RuleCategory,
    r.Severity
FROM dbo.DQRule AS r
INNER JOIN dbo.DQRuleTarget AS t
    ON r.RuleID = t.RuleID
WHERE
    r.RuleCategory = 'COMPLETENESS'
    AND r.Enabled = 1
    AND t.Enabled = 1;


OPEN DQ_NULL_CURSOR;


FETCH NEXT FROM DQ_NULL_CURSOR
INTO
    @RuleID,
    @RuleTargetID,
    @SchemaName,
    @TableName,
    @ColumnName,
    @RuleName,
    @RuleCategory,
    @Severity;


WHILE @@FETCH_STATUS = 0
BEGIN

    -- --------------------------------------------------------
    -- Count total rows
    -- --------------------------------------------------------

    SET @SQL =
        'SELECT @TotalRowsOut = COUNT(*)
         FROM ' + QUOTENAME(@SchemaName) + '.' +
         QUOTENAME(@TableName) + ';';


    EXEC sp_executesql
        @SQL,
        N'@TotalRowsOut INT OUTPUT',
        @TotalRowsOut = @TotalRows OUTPUT;


    -- --------------------------------------------------------
    -- Count NULL values
    -- --------------------------------------------------------

    SET @SQL =
        'SELECT @IssueCountOut = COUNT(*)
         FROM ' + QUOTENAME(@SchemaName) + '.' +
         QUOTENAME(@TableName) +
         ' WHERE ' + QUOTENAME(@ColumnName) + ' IS NULL;';


    EXEC sp_executesql
        @SQL,
        N'@IssueCountOut INT OUTPUT',
        @IssueCountOut = @IssueCount OUTPUT;


    -- --------------------------------------------------------
    -- Determine status
    -- --------------------------------------------------------

    IF @IssueCount = 0
        SET @Status = 'PASS';
    ELSE
        SET @Status = 'FAIL';


    -- --------------------------------------------------------
    -- Create human-readable details
    -- --------------------------------------------------------

    SET @Details =
        CAST(@IssueCount AS VARCHAR(20))
        + ' NULL value(s) found in '
        + @TableName
        + '.'
        + @ColumnName;


    -- --------------------------------------------------------
    -- Store result
    -- --------------------------------------------------------

    INSERT INTO dbo.DQResult
    (
        ResultID,
        RuleID,
        RuleTargetID,
        SchemaName,
        TableName,
        ColumnName,
        RuleName,
        RuleCategory,
        Severity,
        TotalRows,
        IssueCount,
        Status,
        ExecutionTime,
        Details
    )
    VALUES
    (
        'RES_NULL_' + @RuleTargetID,
        @RuleID,
        @RuleTargetID,
        @SchemaName,
        @TableName,
        @ColumnName,
        @RuleName,
        @RuleCategory,
        @Severity,
        @TotalRows,
        @IssueCount,
        @Status,
        GETDATE(),
        @Details
    );


    FETCH NEXT FROM DQ_NULL_CURSOR
    INTO
        @RuleID,
        @RuleTargetID,
        @SchemaName,
        @TableName,
        @ColumnName,
        @RuleName,
        @RuleCategory,
        @Severity;

END;


CLOSE DQ_NULL_CURSOR;
DEALLOCATE DQ_NULL_CURSOR;

SELECT
    ResultID,
    RuleID,
    TableName,
    ColumnName,
    RuleName,
    TotalRows,
    IssueCount,
    Status,
    Details
FROM dbo.DQResult
ORDER BY ResultID;