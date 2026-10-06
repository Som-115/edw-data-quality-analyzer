-- ============================================================
-- 6.4 ORPHAN / REFERENTIAL INTEGRITY CHECK ENGINE
-- ============================================================

DECLARE
    @OrphanRuleID VARCHAR(20),
    @OrphanRuleTargetID VARCHAR(20),
    @OrphanSchemaName VARCHAR(128),
    @OrphanTableName VARCHAR(128),
    @OrphanColumnName VARCHAR(128),
    @ReferenceSchemaName VARCHAR(128),
    @ReferenceTableName VARCHAR(128),
    @ReferenceColumnName VARCHAR(128),
    @OrphanRuleName VARCHAR(100),
    @OrphanRuleCategory VARCHAR(50),
    @OrphanSeverity VARCHAR(20),
    @OrphanSQL NVARCHAR(MAX);

DECLARE
    @OrphanTotalRows INT,
    @OrphanIssueCount INT,
    @OrphanStatus VARCHAR(20),
    @OrphanDetails VARCHAR(1000);


DECLARE DQ_ORPHAN_CURSOR CURSOR FOR

SELECT
    r.RuleID,
    t.RuleTargetID,
    t.SchemaName,
    t.TableName,
    t.ColumnName,
    t.ReferenceSchema,
    t.ReferenceTable,
    t.ReferenceColumn,
    r.RuleName,
    r.RuleCategory,
    r.Severity
FROM dbo.DQRule AS r
INNER JOIN dbo.DQRuleTarget AS t
    ON r.RuleID = t.RuleID
WHERE
    r.RuleCategory = 'REFERENTIAL_INTEGRITY'
    AND r.Enabled = 1
    AND t.Enabled = 1;


OPEN DQ_ORPHAN_CURSOR;


FETCH NEXT FROM DQ_ORPHAN_CURSOR
INTO
    @OrphanRuleID,
    @OrphanRuleTargetID,
    @OrphanSchemaName,
    @OrphanTableName,
    @OrphanColumnName,
    @ReferenceSchemaName,
    @ReferenceTableName,
    @ReferenceColumnName,
    @OrphanRuleName,
    @OrphanRuleCategory,
    @OrphanSeverity;


WHILE @@FETCH_STATUS = 0
BEGIN

    -- --------------------------------------------------------
    -- Count total rows in child table
    -- --------------------------------------------------------

    SET @OrphanSQL =
        'SELECT @TotalRowsOut = COUNT(*)
         FROM ' +
         QUOTENAME(@OrphanSchemaName) + '.' +
         QUOTENAME(@OrphanTableName) + ';';


    EXEC sp_executesql
        @OrphanSQL,
        N'@TotalRowsOut INT OUTPUT',
        @TotalRowsOut = @OrphanTotalRows OUTPUT;


    -- --------------------------------------------------------
    -- Count orphan records
    -- --------------------------------------------------------

    SET @OrphanSQL =
        'SELECT @IssueCountOut = COUNT(*)
         FROM ' +
         QUOTENAME(@OrphanSchemaName) + '.' +
         QUOTENAME(@OrphanTableName) + ' AS Child
         LEFT JOIN ' +
         QUOTENAME(@ReferenceSchemaName) + '.' +
         QUOTENAME(@ReferenceTableName) + ' AS Parent
             ON Child.' +
         QUOTENAME(@OrphanColumnName) +
         ' = Parent.' +
         QUOTENAME(@ReferenceColumnName) +
         ' WHERE Child.' +
         QUOTENAME(@OrphanColumnName) +
         ' IS NOT NULL
         AND Parent.' +
         QUOTENAME(@ReferenceColumnName) +
         ' IS NULL;';


    EXEC sp_executesql
        @OrphanSQL,
        N'@IssueCountOut INT OUTPUT',
        @IssueCountOut = @OrphanIssueCount OUTPUT;


    -- --------------------------------------------------------
    -- Determine status
    -- --------------------------------------------------------

    IF @OrphanIssueCount = 0
        SET @OrphanStatus = 'PASS';
    ELSE
        SET @OrphanStatus = 'FAIL';


    -- --------------------------------------------------------
    -- Create details
    -- --------------------------------------------------------

    SET @OrphanDetails =
        CAST(@OrphanIssueCount AS VARCHAR(20))
        + ' orphan record(s) found in '
        + @OrphanTableName
        + '.'
        + @OrphanColumnName
        + ' referencing '
        + @ReferenceTableName
        + '.'
        + @ReferenceColumnName;


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
        'RES_ORPHAN_' + @OrphanRuleTargetID,
        @OrphanRuleID,
        @OrphanRuleTargetID,
        @OrphanSchemaName,
        @OrphanTableName,
        @OrphanColumnName,
        @OrphanRuleName,
        @OrphanRuleCategory,
        @OrphanSeverity,
        @OrphanTotalRows,
        @OrphanIssueCount,
        @OrphanStatus,
        GETDATE(),
        @OrphanDetails
    );


    FETCH NEXT FROM DQ_ORPHAN_CURSOR
    INTO
        @OrphanRuleID,
        @OrphanRuleTargetID,
        @OrphanSchemaName,
        @OrphanTableName,
        @OrphanColumnName,
        @ReferenceSchemaName,
        @ReferenceTableName,
        @ReferenceColumnName,
        @OrphanRuleName,
        @OrphanRuleCategory,
        @OrphanSeverity;

END;


CLOSE DQ_ORPHAN_CURSOR;
DEALLOCATE DQ_ORPHAN_CURSOR;


SELECT
    ResultID,
    RuleID,
    RuleTargetID,
    TableName,
    ColumnName,
    RuleName,
    TotalRows,
    IssueCount,
    Status,
    Details
FROM dbo.DQResult
WHERE RuleCategory = 'REFERENTIAL_INTEGRITY'
ORDER BY ResultID;