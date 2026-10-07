/* ============================================================
   03_investigation_details.sql
   Phase 8.3 - Investigation Details
   ============================================================ */

DECLARE @TableName VARCHAR(128) = 'JobSubmission';

SELECT
    TableName,
    ColumnName,
    RuleName,
    RuleCategory,
    Severity,
    TotalRows,
    IssueCount,
    Status,
    Details,
    ExecutionTime
FROM dbo.DQResult
WHERE TableName = @TableName
ORDER BY
    CASE Severity
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
        ELSE 5
    END,
    RuleCategory,
    ColumnName;