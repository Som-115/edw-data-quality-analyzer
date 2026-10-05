/* ============================================================
   STEP 5 - METADATA-DRIVEN DATA QUALITY RULES
   Database: Ingest_Bullhorn
   Schema: dbo

   Purpose:
   Stores configurable data quality rules and their targets.
   ============================================================ */


-- ============================================================
-- 1. DQ RULE MASTER
-- ============================================================

CREATE TABLE dbo.DQRule
(
    RuleID              VARCHAR(20) PRIMARY KEY,
    RuleName            VARCHAR(100) NOT NULL,
    RuleCategory        VARCHAR(50) NOT NULL,
    Severity            VARCHAR(20) NOT NULL,
    Description         VARCHAR(500),
    Enabled             BIT NOT NULL
);


-- ============================================================
-- 2. DQ RULE TARGET
-- ============================================================

CREATE TABLE dbo.DQRuleTarget
(
    RuleTargetID        VARCHAR(20) PRIMARY KEY,
    RuleID              VARCHAR(20) NOT NULL,

    SchemaName          VARCHAR(128) NOT NULL,
    TableName           VARCHAR(128) NOT NULL,
    ColumnName          VARCHAR(128),

    ReferenceSchema     VARCHAR(128),
    ReferenceTable      VARCHAR(128),
    ReferenceColumn     VARCHAR(128),

    Threshold           DECIMAL(18,4),

    Enabled             BIT NOT NULL,

    CONSTRAINT FK_DQRuleTarget_DQRule
        FOREIGN KEY (RuleID)
        REFERENCES dbo.DQRule(RuleID)
);


-- ============================================================
-- 3. INSERT DATA QUALITY RULES
-- ============================================================

INSERT INTO dbo.DQRule
(
    RuleID,
    RuleName,
    RuleCategory,
    Severity,
    Description,
    Enabled
)
VALUES

(
    'R001',
    'NULL Value Check',
    'COMPLETENESS',
    'MEDIUM',
    'Checks whether a configured column contains NULL values.',
    1
),

(
    'R002',
    'Duplicate Value Check',
    'UNIQUENESS',
    'MEDIUM',
    'Checks whether a configured column contains duplicate values.',
    1
),

(
    'R003',
    'Orphan Record Check',
    'REFERENTIAL_INTEGRITY',
    'HIGH',
    'Checks whether child records reference a non-existing parent record.',
    1
);


-- ============================================================
-- 4. INSERT DATA QUALITY TARGETS
-- ============================================================


-- Candidate.Email1 NULL check
INSERT INTO dbo.DQRuleTarget
(
    RuleTargetID,
    RuleID,
    SchemaName,
    TableName,
    ColumnName,
    Enabled
)
VALUES
(
    'T001',
    'R001',
    'dbo',
    'Candidate',
    'Email1',
    1
);


-- Candidate.Email1 duplicate check
INSERT INTO dbo.DQRuleTarget
(
    RuleTargetID,
    RuleID,
    SchemaName,
    TableName,
    ColumnName,
    Enabled
)
VALUES
(
    'T002',
    'R002',
    'dbo',
    'Candidate',
    'Email1',
    1
);


-- CandidateEducation.candidateid
-- references Candidate.CandidateID

INSERT INTO dbo.DQRuleTarget
(
    RuleTargetID,
    RuleID,
    SchemaName,
    TableName,
    ColumnName,
    ReferenceSchema,
    ReferenceTable,
    ReferenceColumn,
    Enabled
)
VALUES
(
    'T003',
    'R003',
    'dbo',
    'CandidateEducation',
    'candidateid',
    'dbo',
    'Candidate',
    'CandidateID',
    1
);


-- JobOrder.CompanyID
-- references Company.id

INSERT INTO dbo.DQRuleTarget
(
    RuleTargetID,
    RuleID,
    SchemaName,
    TableName,
    ColumnName,
    ReferenceSchema,
    ReferenceTable,
    ReferenceColumn,
    Enabled
)
VALUES
(
    'T004',
    'R003',
    'dbo',
    'JobOrder',
    'CompanyID',
    'dbo',
    'Company',
    'id',
    1
);


-- JobSubmission.jobOrder
-- references JobOrder.JobID

INSERT INTO dbo.DQRuleTarget
(
    RuleTargetID,
    RuleID,
    SchemaName,
    TableName,
    ColumnName,
    ReferenceSchema,
    ReferenceTable,
    ReferenceColumn,
    Enabled
)
VALUES
(
    'T005',
    'R003',
    'dbo',
    'JobSubmission',
    'jobOrder',
    'dbo',
    'JobOrder',
    'JobID',
    1
);


-- JobSubmission.CandidateID
-- references Candidate.CandidateID

INSERT INTO dbo.DQRuleTarget
(
    RuleTargetID,
    RuleID,
    SchemaName,
    TableName,
    ColumnName,
    ReferenceSchema,
    ReferenceTable,
    ReferenceColumn,
    Enabled
)
VALUES
(
    'T006',
    'R003',
    'dbo',
    'JobSubmission',
    'CandidateID',
    'dbo',
    'Candidate',
    'CandidateID',
    1
);


-- Placement.candidateID
-- references Candidate.CandidateID

INSERT INTO dbo.DQRuleTarget
(
    RuleTargetID,
    RuleID,
    SchemaName,
    TableName,
    ColumnName,
    ReferenceSchema,
    ReferenceTable,
    ReferenceColumn,
    Enabled
)
VALUES
(
    'T007',
    'R003',
    'dbo',
    'Placement',
    'candidateID',
    'dbo',
    'Candidate',
    'CandidateID',
    1
);


-- Placement.jobOrderID
-- references JobOrder.JobID

INSERT INTO dbo.DQRuleTarget
(
    RuleTargetID,
    RuleID,
    SchemaName,
    TableName,
    ColumnName,
    ReferenceSchema,
    ReferenceTable,
    ReferenceColumn,
    Enabled
)
VALUES
(
    'T008',
    'R003',
    'dbo',
    'Placement',
    'jobOrderID',
    'dbo',
    'JobOrder',
    'JobID',
    1
);


-- PlacementCustomObject.PlacementID
-- references Placement.id

INSERT INTO dbo.DQRuleTarget
(
    RuleTargetID,
    RuleID,
    SchemaName,
    TableName,
    ColumnName,
    ReferenceSchema,
    ReferenceTable,
    ReferenceColumn,
    Enabled
)
VALUES
(
    'T009',
    'R003',
    'dbo',
    'PlacementCustomObject',
    'PlacementID',
    'dbo',
    'Placement',
    'id',
    1
);