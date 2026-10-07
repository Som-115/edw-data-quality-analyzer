/* ============================================================
   04_health_impact.sql
   Phase 8.4 - Health + Impact Analysis
   ============================================================ */

DECLARE @TableName VARCHAR(128) = 'Candidate';


/* ============================================================
   1. Health + Impact Summary
   ============================================================ */

WITH DQSummary AS
(
    SELECT
        TableName,

        SUM(
            CASE
                WHEN Status = 'FAIL' AND Severity = 'LOW' THEN 5
                WHEN Status = 'FAIL' AND Severity = 'MEDIUM' THEN 10
                WHEN Status = 'FAIL' AND Severity = 'HIGH' THEN 20
                WHEN Status = 'FAIL' AND Severity = 'CRITICAL' THEN 40
                ELSE 0
            END
        ) AS TotalDeduction,

        COUNT(*) AS TotalChecks,

        SUM(
            CASE
                WHEN Status = 'PASS' THEN 1
                ELSE 0
            END
        ) AS PassedChecks,

        SUM(
            CASE
                WHEN Status = 'FAIL' THEN 1
                ELSE 0
            END
        ) AS FailedChecks,

        SUM(IssueCount) AS TotalIssues

    FROM dbo.DQResult
    WHERE TableName = @TableName
    GROUP BY TableName
),

Health AS
(
    SELECT
        TableName,

        CASE
            WHEN 100 - TotalDeduction < 0 THEN 0
            ELSE 100 - TotalDeduction
        END AS HealthScore,

        TotalChecks,
        PassedChecks,
        FailedChecks,
        TotalIssues,

        CASE
            WHEN 100 - TotalDeduction >= 90 THEN 'HEALTHY'
            WHEN 100 - TotalDeduction >= 75 THEN 'GOOD'
            WHEN 100 - TotalDeduction >= 50 THEN 'NEEDS_ATTENTION'
            ELSE 'CRITICAL'
        END AS HealthStatus

    FROM DQSummary
),

Relationships AS
(
    /* Physical Foreign Keys */

    SELECT
        'PHYSICAL_FK' AS RelationshipType,
        childTable.name AS ChildTable,
        childColumn.name AS ChildColumn,
        parentTable.name AS ParentTable,
        parentColumn.name AS ParentColumn,
        fk.name AS RelationshipName

    FROM sys.foreign_keys AS fk

    INNER JOIN sys.foreign_key_columns AS fkc
        ON fk.object_id = fkc.constraint_object_id

    INNER JOIN sys.tables AS childTable
        ON fkc.parent_object_id = childTable.object_id

    INNER JOIN sys.columns AS childColumn
        ON fkc.parent_object_id = childColumn.object_id
        AND fkc.parent_column_id = childColumn.column_id

    INNER JOIN sys.tables AS parentTable
        ON fkc.referenced_object_id = parentTable.object_id

    INNER JOIN sys.columns AS parentColumn
        ON fkc.referenced_object_id = parentColumn.object_id
        AND fkc.referenced_column_id = parentColumn.column_id

    WHERE childTable.name = @TableName
       OR parentTable.name = @TableName


    UNION ALL


    /* Configured Logical References */

    SELECT
        'CONFIGURED_REFERENCE' AS RelationshipType,
        t.TableName AS ChildTable,
        t.ColumnName AS ChildColumn,
        t.ReferenceTable AS ParentTable,
        t.ReferenceColumn AS ParentColumn,
        t.RuleTargetID AS RelationshipName

    FROM dbo.DQRuleTarget AS t

    INNER JOIN dbo.DQRule AS r
        ON t.RuleID = r.RuleID

    WHERE t.Enabled = 1
      AND r.Enabled = 1
      AND r.RuleCategory = 'REFERENTIAL_INTEGRITY'
      AND (
            t.TableName = @TableName
            OR t.ReferenceTable = @TableName
          )
)

SELECT
    h.TableName,
    h.HealthScore,
    h.HealthStatus,
    h.TotalChecks,
    h.PassedChecks,
    h.FailedChecks,
    h.TotalIssues,

    COUNT(r.RelationshipName) AS TotalRelationships,

    SUM(
        CASE
            WHEN r.ChildTable = @TableName THEN 1
            ELSE 0
        END
    ) AS UpstreamCount,

    SUM(
        CASE
            WHEN r.ParentTable = @TableName THEN 1
            ELSE 0
        END
    ) AS DownstreamCount

FROM Health AS h

LEFT JOIN Relationships AS r
    ON 1 = 1

GROUP BY
    h.TableName,
    h.HealthScore,
    h.HealthStatus,
    h.TotalChecks,
    h.PassedChecks,
    h.FailedChecks,
    h.TotalIssues;


/* ============================================================
   2. Relationship Details
   ============================================================ */

WITH Relationships AS
(
    /* Physical Foreign Keys */

    SELECT
        'PHYSICAL_FK' AS RelationshipType,
        childTable.name AS ChildTable,
        childColumn.name AS ChildColumn,
        parentTable.name AS ParentTable,
        parentColumn.name AS ParentColumn,
        fk.name AS RelationshipName

    FROM sys.foreign_keys AS fk

    INNER JOIN sys.foreign_key_columns AS fkc
        ON fk.object_id = fkc.constraint_object_id

    INNER JOIN sys.tables AS childTable
        ON fkc.parent_object_id = childTable.object_id

    INNER JOIN sys.columns AS childColumn
        ON fkc.parent_object_id = childColumn.object_id
        AND fkc.parent_column_id = childColumn.column_id

    INNER JOIN sys.tables AS parentTable
        ON fkc.referenced_object_id = parentTable.object_id

    INNER JOIN sys.columns AS parentColumn
        ON fkc.referenced_object_id = parentColumn.object_id
        AND fkc.referenced_column_id = parentColumn.column_id

    WHERE childTable.name = @TableName
       OR parentTable.name = @TableName


    UNION ALL


    /* Configured Logical References */

    SELECT
        'CONFIGURED_REFERENCE' AS RelationshipType,
        t.TableName AS ChildTable,
        t.ColumnName AS ChildColumn,
        t.ReferenceTable AS ParentTable,
        t.ReferenceColumn AS ParentColumn,
        t.RuleTargetID AS RelationshipName

    FROM dbo.DQRuleTarget AS t

    INNER JOIN dbo.DQRule AS r
        ON t.RuleID = r.RuleID

    WHERE t.Enabled = 1
      AND r.Enabled = 1
      AND r.RuleCategory = 'REFERENTIAL_INTEGRITY'
      AND (
            t.TableName = @TableName
            OR t.ReferenceTable = @TableName
          )
)

SELECT
    CASE
        WHEN ChildTable = @TableName THEN 'UPSTREAM'
        ELSE 'DOWNSTREAM'
    END AS Direction,

    RelationshipType,

    CASE
        WHEN ChildTable = @TableName THEN ParentTable
        ELSE ChildTable
    END AS RelatedTable,

    ChildColumn,
    ParentColumn,
    RelationshipName

FROM Relationships

ORDER BY
    CASE
        WHEN ChildTable = @TableName THEN 1
        ELSE 2
    END,
    RelatedTable;