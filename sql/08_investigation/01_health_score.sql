/* ============================================================
   08_health_score.sql
   Phase 8.1 - Table Health Score
   ============================================================ */

-- DECLARE @TableName VARCHAR(128) = 'Candidate';
DECLARE @TableName VARCHAR(128) = 'JobOrder';

WITH DQSummary AS
(
    SELECT
        TableName,

        SUM(
            CASE
                WHEN Status = 'FAIL' AND Severity = 'LOW'
                    THEN 5

                WHEN Status = 'FAIL' AND Severity = 'MEDIUM'
                    THEN 10

                WHEN Status = 'FAIL' AND Severity = 'HIGH'
                    THEN 20

                WHEN Status = 'FAIL' AND Severity = 'CRITICAL'
                    THEN 40

                ELSE 0
            END
        ) AS TotalDeduction,

        COUNT(*) AS TotalChecks,

        SUM(
            CASE
                WHEN Status = 'PASS'
                    THEN 1
                ELSE 0
            END
        ) AS PassedChecks,

        SUM(
            CASE
                WHEN Status = 'FAIL'
                    THEN 1
                ELSE 0
            END
        ) AS FailedChecks,

        SUM(IssueCount) AS TotalIssues

    FROM dbo.DQResult

    WHERE TableName = @TableName

    GROUP BY TableName
)

SELECT
    TableName,

    CASE
        WHEN 100 - TotalDeduction < 0
            THEN 0
        ELSE 100 - TotalDeduction
    END AS HealthScore,

    TotalChecks,
    PassedChecks,
    FailedChecks,
    TotalIssues,

    CASE
        WHEN 100 - TotalDeduction >= 90
            THEN 'HEALTHY'

        WHEN 100 - TotalDeduction >= 75
            THEN 'GOOD'

        WHEN 100 - TotalDeduction >= 50
            THEN 'NEEDS_ATTENTION'

        ELSE 'CRITICAL'
    END AS HealthStatus

FROM DQSummary;