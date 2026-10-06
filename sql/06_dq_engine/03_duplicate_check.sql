-- ============================================================
-- 6.3 DUPLICATE CHECK ENGINE
-- ============================================================

DECLARE
    @DupRuleID VARCHAR(20),
    @DupRuleTargetID VARCHAR(20),
    @DupSchemaName VARCHAR(128),
    @DupTableName VARCHAR(128),
    @DupColumnName VARCHAR(128),
    @DupRuleName VARCHAR(100),
    @DupRuleCategory VARCHAR(50),
    @DupSeverity VARCHAR(20),
    @DupSQL NVARCHAR(MAX);

DECLARE
    @DupTotalRows INT,
    @DupIssueCount INT,
    @DupStatus VARCHAR(20),
    @DupDetails VARCHAR(1000);


DECLARE DQ_DUPLICATE_CURSOR CURSOR FOR

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
    r.RuleCategory = 'UNIQUENESS'
    AND r.Enabled = 1
    AND t.Enabled = 1;


OPEN DQ_DUPLICATE_CURSOR;


FETCH NEXT FROM DQ_DUPLICATE_CURSOR
INTO
    @DupRuleID,
    @DupRuleTargetID,
    @DupSchemaName,
    @DupTableName,
    @DupColumnName,
    @DupRuleName,
    @DupRuleCategory,
    @DupSeverity;


WHILE @@FETCH_STATUS = 0
BEGIN

    -- --------------------------------------------------------
    -- Count total rows
    -- --------------------------------------------------------

    SET @DupSQL =
        'SELECT @TotalRowsOut = COUNT(*)
         FROM ' + QUOTENAME(@DupSchemaName) + '.' +
         QUOTENAME(@DupTableName) + ';';


    EXEC sp_executesql
        @DupSQL,
        N'@TotalRowsOut INT OUTPUT',
        @TotalRowsOut = @DupTotalRows OUTPUT;


    -- --------------------------------------------------------
    -- Count duplicate groups
    -- NULL values are excluded
    -- --------------------------------------------------------

    SET @DupSQL =
        'SELECT @IssueCountOut = COUNT(*)
         FROM
         (
             SELECT ' + QUOTENAME(@DupColumnName) + '
             FROM ' + QUOTENAME(@DupSchemaName) + '.' +
             QUOTENAME(@DupTableName) + '
             WHERE ' + QUOTENAME(@DupColumnName) + ' IS NOT NULL
             GROUP BY ' + QUOTENAME(@DupColumnName) + '
             HAVING COUNT(*) > 1
         ) AS DuplicateGroups;';


    EXEC sp_executesql
        @DupSQL,
        N'@IssueCountOut INT OUTPUT',
        @IssueCountOut = @DupIssueCount OUTPUT;


    -- --------------------------------------------------------
    -- Determine status
    -- --------------------------------------------------------

    IF @DupIssueCount = 0
        SET @DupStatus = 'PASS';
    ELSE
        SET @DupStatus = 'FAIL';


    -- --------------------------------------------------------
    -- Create details
    -- --------------------------------------------------------

    SET @DupDetails =
        CAST(@DupIssueCount AS VARCHAR(20))
        + ' duplicate value group(s) found in '
        + @DupTableName
        + '.'
        + @DupColumnName;


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
        'RES_DUP_' + @DupRuleTargetID,
        @DupRuleID,
        @DupRuleTargetID,
        @DupSchemaName,
        @DupTableName,
        @DupColumnName,
        @DupRuleName,
        @DupRuleCategory,
        @DupSeverity,
        @DupTotalRows,
        @DupIssueCount,
        @DupStatus,
        GETDATE(),
        @DupDetails
    );


    FETCH NEXT FROM DQ_DUPLICATE_CURSOR
    INTO
        @DupRuleID,
        @DupRuleTargetID,
        @DupSchemaName,
        @DupTableName,
        @DupColumnName,
        @DupRuleName,
        @DupRuleCategory,
        @DupSeverity;

END;


CLOSE DQ_DUPLICATE_CURSOR;
DEALLOCATE DQ_DUPLICATE_CURSOR;


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

