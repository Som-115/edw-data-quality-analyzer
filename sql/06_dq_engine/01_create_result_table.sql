/* ============================================================
   STEP 6 - DATA QUALITY ENGINE
   Database: Ingest_Bullhorn
   Schema: dbo

   Purpose:
   Stores standardized results produced by the DQ engine.
   ============================================================ */

-- ============================================================
-- 1. DQ RESULT TABLE
-- ============================================================

CREATE TABLE dbo.DQResult
(
    ResultID            VARCHAR(30) PRIMARY KEY,

    RuleID              VARCHAR(20) NOT NULL,
    RuleTargetID        VARCHAR(20) NOT NULL,

    SchemaName          VARCHAR(128) NOT NULL,
    TableName           VARCHAR(128) NOT NULL,
    ColumnName          VARCHAR(128),

    RuleName            VARCHAR(100) NOT NULL,
    RuleCategory        VARCHAR(50) NOT NULL,
    Severity            VARCHAR(20) NOT NULL,

    TotalRows           INT,
    IssueCount          INT,

    Status              VARCHAR(20) NOT NULL,

    ExecutionTime       DATETIME2,

    Details             VARCHAR(1000)
);