-- 6.5 run all checks together 
SELECT
    ResultID,
    RuleID,
    RuleTargetID,
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
FROM dbo.DQResult
ORDER BY
    RuleCategory,
    TableName,
    ColumnName;