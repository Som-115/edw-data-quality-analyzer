/* ============================================================
   STEP 7 - IMPACT ANALYSIS
   7.1 Confirmed FK Dependency Map
   ============================================================ */

SELECT
    fk.name AS ForeignKeyName,

    SCHEMA_NAME(childTable.schema_id) AS ChildSchema,
    childTable.name AS ChildTable,
    childColumn.name AS ChildColumn,

    SCHEMA_NAME(parentTable.schema_id) AS ParentSchema,
    parentTable.name AS ParentTable,
    parentColumn.name AS ParentColumn

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

WHERE
    SCHEMA_NAME(childTable.schema_id) = 'dbo'

ORDER BY
    ParentTable,
    ChildTable;


/* ============================================================
   7.2 Find Direct Impact / Dependents
   ============================================================ */

/* ============================================================
   7.2 COMBINED IMPACT ANALYSIS

   Finds relationships from:
   1. Physical database foreign keys
   2. Configured DQRuleTarget references

   RelationshipType:
   PHYSICAL_FK
   CONFIGURED_REFERENCE
   ============================================================ */

DECLARE @TableName VARCHAR(128) = 'Candidate';
-- DECLARE @TableName VARCHAR(128) = 'JobOrder';
-- DECLARE @TableName VARCHAR(128) = 'Placement';

-- ============================================================
-- PART 1: PHYSICAL FOREIGN KEY RELATIONSHIPS
-- ============================================================

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

WHERE
    childTable.name = @TableName
    OR parentTable.name = @TableName


UNION ALL


-- ============================================================
-- PART 2: CONFIGURED REFERENCE RELATIONSHIPS
-- ============================================================

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

WHERE
    t.Enabled = 1
    AND r.Enabled = 1
    AND r.RuleCategory = 'REFERENTIAL_INTEGRITY'
    AND
    (
        t.TableName = @TableName
        OR t.ReferenceTable = @TableName
    )


ORDER BY
    RelationshipType,
    ChildTable,
    ParentTable;


/* ============================================================
   7.3 RELATIONSHIP DIRECTION & IMPACT SUMMARY

   UPSTREAM:
       Selected table depends on another table.

   DOWNSTREAM:
       Another table depends on the selected table.
   ============================================================ */

DECLARE @TableName VARCHAR(128) = 'Candidate';


-- ============================================================
-- PHYSICAL FK RELATIONSHIPS
-- ============================================================

SELECT
    'PHYSICAL_FK' AS RelationshipType,

    CASE
        WHEN childTable.name = @TableName
            THEN 'UPSTREAM'
        ELSE 'DOWNSTREAM'
    END AS Direction,

    CASE
        WHEN childTable.name = @TableName
            THEN parentTable.name
        ELSE childTable.name
    END AS RelatedTable,

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

WHERE
    childTable.name = @TableName
    OR parentTable.name = @TableName


UNION ALL


-- ============================================================
-- CONFIGURED REFERENCE RELATIONSHIPS
-- ============================================================

SELECT
    'CONFIGURED_REFERENCE' AS RelationshipType,

    CASE
        WHEN t.TableName = @TableName
            THEN 'UPSTREAM'
        ELSE 'DOWNSTREAM'
    END AS Direction,

    CASE
        WHEN t.TableName = @TableName
            THEN t.ReferenceTable
        ELSE t.TableName
    END AS RelatedTable,

    t.TableName AS ChildTable,
    t.ColumnName AS ChildColumn,

    t.ReferenceTable AS ParentTable,
    t.ReferenceColumn AS ParentColumn,

    t.RuleTargetID AS RelationshipName

FROM dbo.DQRuleTarget AS t

INNER JOIN dbo.DQRule AS r
    ON t.RuleID = r.RuleID

WHERE
    t.Enabled = 1
    AND r.Enabled = 1
    AND r.RuleCategory = 'REFERENTIAL_INTEGRITY'
    AND
    (
        t.TableName = @TableName
        OR t.ReferenceTable = @TableName
    )

ORDER BY
    Direction,
    RelationshipType,
    RelatedTable;


/* ============================================================
   7.3.1 IMPACT SUMMARY
   ============================================================ */

DECLARE @TableName VARCHAR(128) = 'Candidate';

WITH Relationships AS
(
    -- Physical FK relationships
    SELECT
        CASE
            WHEN childTable.name = @TableName
                THEN 'UPSTREAM'
            ELSE 'DOWNSTREAM'
        END AS Direction

    FROM sys.foreign_keys AS fk

    INNER JOIN sys.foreign_key_columns AS fkc
        ON fk.object_id = fkc.constraint_object_id

    INNER JOIN sys.tables AS childTable
        ON fkc.parent_object_id = childTable.object_id

    INNER JOIN sys.tables AS parentTable
        ON fkc.referenced_object_id = parentTable.object_id

    WHERE
        childTable.name = @TableName
        OR parentTable.name = @TableName


    UNION ALL


    -- Configured reference relationships
    SELECT
        CASE
            WHEN t.TableName = @TableName
                THEN 'UPSTREAM'
            ELSE 'DOWNSTREAM'
        END AS Direction

    FROM dbo.DQRuleTarget AS t

    INNER JOIN dbo.DQRule AS r
        ON t.RuleID = r.RuleID

    WHERE
        t.Enabled = 1
        AND r.Enabled = 1
        AND r.RuleCategory = 'REFERENTIAL_INTEGRITY'
        AND
        (
            t.TableName = @TableName
            OR t.ReferenceTable = @TableName
        )
)

SELECT
    @TableName AS TableName,

    SUM(
        CASE
            WHEN Direction = 'UPSTREAM' THEN 1
            ELSE 0
        END
    ) AS UpstreamCount,

    SUM(
        CASE
            WHEN Direction = 'DOWNSTREAM' THEN 1
            ELSE 0
        END
    ) AS DownstreamCount,

    COUNT(*) AS TotalRelationships

FROM Relationships;