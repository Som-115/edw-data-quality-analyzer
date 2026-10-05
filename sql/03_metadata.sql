/* ============================================================
   1. TABLE INVENTORY
   ============================================================ */

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;


/* ============================================================
   2. COLUMN METADATA
   ============================================================ */

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;


/* ============================================================
   3. PRIMARY KEYS
   ============================================================ */

SELECT
    tc.TABLE_SCHEMA,
    tc.TABLE_NAME,
    kcu.COLUMN_NAME,
    tc.CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
    AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA
    AND tc.TABLE_NAME = kcu.TABLE_NAME
WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
  AND tc.TABLE_SCHEMA = 'dbo'
ORDER BY
    tc.TABLE_NAME,
    kcu.ORDINAL_POSITION;


/* ============================================================
   4. FOREIGN KEYS
   ============================================================ */

SELECT
    fk.TABLE_SCHEMA AS ChildSchema,
    fk.TABLE_NAME AS ChildTable,
    fk.COLUMN_NAME AS ChildColumn,
    pk.TABLE_SCHEMA AS ParentSchema,
    pk.TABLE_NAME AS ParentTable,
    pk.COLUMN_NAME AS ParentColumn,
    fk.CONSTRAINT_NAME AS ForeignKeyName
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE fk
    ON rc.CONSTRAINT_NAME = fk.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE pk
    ON rc.UNIQUE_CONSTRAINT_NAME = pk.CONSTRAINT_NAME
WHERE fk.TABLE_SCHEMA = 'dbo'
ORDER BY
    fk.TABLE_NAME;


/* ============================================================
   5. ROW COUNTS
   ============================================================ */

SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    SUM(p.rows) AS TotalRows
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id
INNER JOIN sys.partitions AS p
    ON t.object_id = p.object_id
WHERE
    p.index_id IN (0, 1)
    AND s.name = 'dbo'
GROUP BY
    s.name,
    t.name
ORDER BY
    t.name;
