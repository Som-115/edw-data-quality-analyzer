TABLE_LIST_QUERY = """
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
"""


COLUMN_COUNT_QUERY = """
SELECT COUNT(*)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = ?;
"""


# PRIMARY_KEY_QUERY = """
# SELECT COLUMN_NAME
# FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
# WHERE TABLE_SCHEMA = 'dbo'
#   AND TABLE_NAME = ?
# ORDER BY ORDINAL_POSITION;
# """

PRIMARY_KEY_QUERY = """
SELECT KCU.COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU
INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
    ON KCU.CONSTRAINT_NAME = TC.CONSTRAINT_NAME
    AND KCU.TABLE_SCHEMA = TC.TABLE_SCHEMA
    AND KCU.TABLE_NAME = TC.TABLE_NAME
WHERE KCU.TABLE_SCHEMA = 'dbo'
  AND KCU.TABLE_NAME = ?
  AND TC.CONSTRAINT_TYPE = 'PRIMARY KEY'
ORDER BY KCU.ORDINAL_POSITION;
"""


HEALTH_QUERY = """
SELECT
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

    COALESCE(SUM(IssueCount), 0) AS TotalIssues,

    COALESCE(
        SUM(
            CASE Severity
                WHEN 'LOW' THEN
                    CASE WHEN Status = 'FAIL' THEN 5 ELSE 0 END

                WHEN 'MEDIUM' THEN
                    CASE WHEN Status = 'FAIL' THEN 10 ELSE 0 END

                WHEN 'HIGH' THEN
                    CASE WHEN Status = 'FAIL' THEN 20 ELSE 0 END

                WHEN 'CRITICAL' THEN
                    CASE WHEN Status = 'FAIL' THEN 40 ELSE 0 END

                ELSE 0
            END
        ),
        0
    ) AS Deduction

FROM dbo.DQResult
WHERE TableName = ?;
"""

DQ_RESULTS_QUERY = """
SELECT
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
WHERE TableName = ?
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
"""

# ============================================================
# IMPACT ANALYSIS
# ============================================================

# ============================================================
# IMPACT ANALYSIS
# ============================================================

IMPACT_ANALYSIS_QUERY = """
WITH SelectedTable AS
(
    SELECT ? AS TableName
),

Relationships AS
(
    -- ========================================================
    -- PHYSICAL FOREIGN KEY - UPSTREAM
    -- ========================================================

    SELECT
        'UPSTREAM' AS RelationshipDirection,
        'PHYSICAL_FK' AS RelationshipType,
        rt.name AS RelatedTable,
        pc.name AS SourceColumn,
        rc.name AS RelatedColumn,
        1 AS DirectionOrder,
        1 AS TypeOrder

    FROM sys.foreign_key_columns AS fkc

    INNER JOIN sys.tables AS pt
        ON fkc.parent_object_id = pt.object_id

    INNER JOIN sys.schemas AS ps
        ON pt.schema_id = ps.schema_id

    INNER JOIN sys.columns AS pc
        ON fkc.parent_object_id = pc.object_id
        AND fkc.parent_column_id = pc.column_id

    INNER JOIN sys.tables AS rt
        ON fkc.referenced_object_id = rt.object_id

    INNER JOIN sys.schemas AS rs
        ON rt.schema_id = rs.schema_id

    INNER JOIN sys.columns AS rc
        ON fkc.referenced_object_id = rc.object_id
        AND fkc.referenced_column_id = rc.column_id

    CROSS JOIN SelectedTable AS st

    WHERE ps.name = 'dbo'
      AND rs.name = 'dbo'
      AND pt.name = st.TableName


    UNION ALL


    -- ========================================================
    -- PHYSICAL FOREIGN KEY - DOWNSTREAM
    -- ========================================================

    SELECT
        'DOWNSTREAM' AS RelationshipDirection,
        'PHYSICAL_FK' AS RelationshipType,
        pt.name AS RelatedTable,
        pc.name AS SourceColumn,
        rc.name AS RelatedColumn,
        2 AS DirectionOrder,
        1 AS TypeOrder

    FROM sys.foreign_key_columns AS fkc

    INNER JOIN sys.tables AS pt
        ON fkc.parent_object_id = pt.object_id

    INNER JOIN sys.schemas AS ps
        ON pt.schema_id = ps.schema_id

    INNER JOIN sys.columns AS pc
        ON fkc.parent_object_id = pc.object_id
        AND fkc.parent_column_id = pc.column_id

    INNER JOIN sys.tables AS rt
        ON fkc.referenced_object_id = rt.object_id

    INNER JOIN sys.schemas AS rs
        ON rt.schema_id = rs.schema_id

    INNER JOIN sys.columns AS rc
        ON fkc.referenced_object_id = rc.object_id
        AND fkc.referenced_column_id = rc.column_id

    CROSS JOIN SelectedTable AS st

    WHERE ps.name = 'dbo'
      AND rs.name = 'dbo'
      AND rt.name = st.TableName


    UNION ALL


    -- ========================================================
    -- CONFIGURED REFERENCE - UPSTREAM
    -- ========================================================

    SELECT
        'UPSTREAM' AS RelationshipDirection,
        'CONFIGURED_REFERENCE' AS RelationshipType,
        drt.ReferenceTable AS RelatedTable,
        drt.ColumnName AS SourceColumn,
        drt.ReferenceColumn AS RelatedColumn,
        1 AS DirectionOrder,
        2 AS TypeOrder

    FROM dbo.DQRuleTarget AS drt

    CROSS JOIN SelectedTable AS st

    WHERE drt.Enabled = 1
      AND drt.SchemaName = 'dbo'
      AND drt.ReferenceSchema = 'dbo'
      AND drt.TableName = st.TableName


    UNION ALL


    -- ========================================================
    -- CONFIGURED REFERENCE - DOWNSTREAM
    -- ========================================================

    SELECT
        'DOWNSTREAM' AS RelationshipDirection,
        'CONFIGURED_REFERENCE' AS RelationshipType,
        drt.TableName AS RelatedTable,
        drt.ColumnName AS SourceColumn,
        drt.ReferenceColumn AS RelatedColumn,
        2 AS DirectionOrder,
        2 AS TypeOrder

    FROM dbo.DQRuleTarget AS drt

    CROSS JOIN SelectedTable AS st

    WHERE drt.Enabled = 1
      AND drt.SchemaName = 'dbo'
      AND drt.ReferenceSchema = 'dbo'
      AND drt.ReferenceTable = st.TableName
)

SELECT
    RelationshipDirection,
    RelationshipType,
    RelatedTable,
    SourceColumn,
    RelatedColumn

FROM Relationships

ORDER BY
    DirectionOrder,
    TypeOrder,
    RelatedTable;
"""