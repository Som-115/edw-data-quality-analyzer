/*
============================================================
EDW Data Quality & Investigation Analyzer
Synthetic Test Data

Purpose:
- Populate the prototype database
- Create realistic relationships
- Intentionally introduce data-quality issues
- Provide test cases for the analyzer

IMPORTANT:
This is synthetic data only.
============================================================
*/


/* ============================================================
   1. EDWAudit
   ============================================================ */

INSERT INTO dbo.EDWAudit (EDWAuditID)
VALUES
    (1001),
    (1002),
    (1003);


/* ============================================================
   2. Country
   ============================================================ */

INSERT INTO dbo.Country
(
    id,
    Name,
    EDWAuditID
)
VALUES
    (1, 'India', 1001),
    (2, 'United States', 1001),
    (3, 'United Kingdom', 1002),
    (4, 'Canada', 1002),
    (5, 'Australia', 1003);


/* ============================================================
   3. Company
   ============================================================ */

INSERT INTO dbo.Company
(
    id,
    OperationsManager,
    Salesforceid,
    status,
    CompanyName,
    companyURL,
    Ownership,
    YearFounded,
    CompanyDescription,
    Phone,
    City,
    EDWAuditID
)
VALUES
    (101, 'Anita Rao', 'SF001', 'Active',
     'Acme Corporation', 'https://acme.example.com',
     'Private', '2005', 'Technology services company',
     '9000000001', 'Bangalore', 1001),

    (102, 'Rahul Mehta', 'SF002', 'Active',
     'Global Solutions', 'https://global.example.com',
     'Private', '2010', 'Business consulting company',
     '9000000002', 'Mumbai', 1001),

    (103, 'Priya Nair', 'SF003', 'Active',
     'DataWorks', 'https://dataworks.example.com',
     'Public', '2015', 'Data and analytics company',
     '9000000003', 'Chennai', 1002),

    (104, 'Sneha Iyer', 'SF004', 'Inactive',
     'TechNova', 'https://technova.example.com',
     'Private', '2008', 'Software company',
     '9000000004', 'Hyderabad', 1003);


/* ============================================================
   4. CorporateUser
   ============================================================ */

INSERT INTO dbo.CorporateUser
(
    id,
    isHidden,
    isLockedOut,
    lastName,
    middleName,
    mobile,
    name,
    occupation,
    phone,
    status,
    username,
    EDWAuditID
)
VALUES
    (201, '0', '0', 'Sharma', NULL, '9000010001',
     'Amit Sharma', 'Recruiter', '9000010001',
     'Active', 'amit.sharma', 1001),

    (202, '0', '0', 'Reddy', NULL, '9000010002',
     'Neha Reddy', 'Recruiter', '9000010002',
     'Active', 'neha.reddy', 1001),

    (203, '0', '0', 'Thomas', NULL, '9000010003',
     'John Thomas', 'Manager', '9000010003',
     'Active', 'john.thomas', 1002);


/* ============================================================
   5. ClientContact
   ============================================================ */

INSERT INTO dbo.ClientContact
(
    ID,
    FirstName,
    LastName,
    ADUsername,
    AD_GUID,
    Email,
    ADEmail,
    DateLastModified,
    DateAdded,
    isDeleted,
    EDWAuditID
)
VALUES
    ('CC001', 'Arun', 'Kumar', 'arun.kumar', 'GUID-001',
     'arun@acme.example.com', 'arun@acme.example.com',
     '2026-09-01', '2026-01-10', '0', 1001),

    ('CC002', 'Meera', 'Shah', 'meera.shah', 'GUID-002',
     'meera@global.example.com', 'meera@global.example.com',
     '2026-09-05', '2026-02-15', '0', 1001);


/* ============================================================
   6. Candidate
   ============================================================ */

INSERT INTO dbo.Candidate
(
    Email1,
    FirstName,
    LastName,
    UKGBaseRate,
    BarStatus,
    ConsilioServicesRole,
    [Ultipro#],
    Payroll,
    CandidateID,
    EMAIL3,
    Email2,
    status,
    DateAdded,
    DateLastModified,
    OwnerID,
    OwnerFirstName,
    OwnerLastName,
    CountryID,
    IsDeleted,
    EDWAuditID
)
VALUES
    (
        'ananya@example.com',
        'Ananya',
        'Rao',
        '50000',
        'Clear',
        'Data Engineer',
        'U001',
        'India',
        10001,
        NULL,
        NULL,
        'Active',
        '2026-01-10',
        '2026-09-01',
        201,
        'Amit',
        'Sharma',
        1,
        0,
        1001
    ),

    (
        'rahul@example.com',
        'Rahul',
        'Kumar',
        '45000',
        'Clear',
        'QA Engineer',
        'U002',
        'India',
        10002,
        NULL,
        NULL,
        'Active',
        '2026-02-15',
        '2026-09-02',
        202,
        'Neha',
        'Reddy',
        1,
        0,
        1001
    ),

    (
        NULL,
        'Priya',
        'Sharma',
        '55000',
        'Clear',
        'Data Analyst',
        'U003',
        'India',
        10003,
        NULL,
        NULL,
        'Active',
        '2026-03-01',
        '2026-09-03',
        201,
        'Amit',
        'Sharma',
        1,
        0,
        1002
    ),

    (
        'ananya@example.com',
        'Priya',
        'Nair',
        '60000',
        'Clear',
        'Software Engineer',
        'U004',
        'India',
        10004,
        NULL,
        NULL,
        'Active',
        '2026-03-10',
        '2026-09-04',
        203,
        'John',
        'Thomas',
        1,
        0,
        1002
    ),

    (
        'deleted@example.com',
        'Deleted',
        'Candidate',
        '40000',
        'Clear',
        'QA Engineer',
        'U005',
        'India',
        10005,
        NULL,
        NULL,
        'Inactive',
        '2026-04-01',
        '2026-09-05',
        202,
        'Neha',
        'Reddy',
        1,
        1,
        1003
    );


/* ============================================================
   7. CandidateEducation
   ============================================================ */

INSERT INTO dbo.CandidateEducation
(
    id,
    candidateid,
    firstName,
    lastName,
    certification,
    city,
    comments,
    VerifiedDate,
    VerifiedBy,
    dateAdded,
    dateLastModified,
    degree,
    endDate,
    expirationDate,
    gpa,
    graduationDate,
    isDeleted,
    major,
    school,
    startDate,
    state,
    EDWAuditID
)
VALUES
    (
        1, 10001, 'Ananya', 'Rao',
        'Azure Fundamentals', 'Bangalore',
        'Verified education record',
        '2026-02-01', 'Amit Sharma',
        '2026-01-10', '2026-02-01',
        'B.E.', '2025-06-01', NULL,
        8.6, '2025-06-01',
        0, 'Computer Science',
        'Engineering College',
        '2021-08-01', 'Karnataka', 1001
    ),

    (
        2, 10002, 'Rahul', 'Kumar',
        NULL, 'Mumbai',
        'Certification not provided',
        NULL, NULL,
        '2026-02-15', '2026-02-15',
        'B.E.', '2025-06-01', NULL,
        7.8, '2025-06-01',
        0, 'Information Technology',
        'Engineering College',
        '2021-08-01', 'Maharashtra', 1001
    ),

    (
        3, 99999, 'Unknown', 'Candidate',
        NULL, NULL,
        'Intentional orphan candidate reference',
        NULL, NULL,
        '2026-03-01', '2026-03-01',
        'B.Tech', NULL, NULL,
        NULL, NULL,
        0, 'Computer Science',
        'Unknown College',
        NULL, NULL, 1002
    );


/* ============================================================
   8. JobOrder
   ============================================================ */

INSERT INTO dbo.JobOrder
(
    CompanyID,
    CompanyName,
    Hcode,
    Jobtitle,
    StartDate,
    RMEmailAddress,
    ReadyforStaffingRequest,
    ProjectStartTime,
    ExternalPlatformURL,
    InternallyHosted,
    PlatformGeography,
    RelativityServer,
    RelativityWorkspace,
    RelativitySecurityGroup,
    [W365/SVR],
    [Open/Closed],
    Status,
    EngagementNumber,
    JobID,
    LastModifiedDate,
    DateAdded,
    ScheduledEndDate,
    EmploymentType,
    IsDeleted,
    SlTAIntegrationStatus,
    SF_Opp_ID,
    EDWAuditID
)
VALUES
    (
        101, 'Acme Corporation', 'HC001',
        'Data Engineer', '2026-10-01',
        'manager@acme.example.com',
        'Yes', '09:00',
        'https://acme.example.com/job/1001',
        'Yes', 'India', NULL, NULL, NULL,
        'W365', 1, 'Open', 'ENG-001',
        1001, '2026-09-20', '2026-09-01',
        '2027-03-01', 'Full Time', 0,
        'Success', 'OPP001', 1001
    ),

    (
        102, 'Global Solutions', 'HC002',
        'QA Engineer', '2026-10-05',
        'manager@global.example.com',
        'Yes', '10:00',
        'https://global.example.com/job/1002',
        'Yes', 'India', NULL, NULL, NULL,
        'SVR', 1, 'Open', 'QA-001',
        1002, '2026-09-21', '2026-09-02',
        '2027-04-01', 'Full Time', 0,
        'Success', 'OPP002', 1001
    ),

    (
        103, 'DataWorks', 'HC003',
        'Data Analyst', '2026-10-10',
        NULL,
        'No', '11:00',
        NULL,
        'No', 'India', NULL, NULL, NULL,
        NULL, 0, 'Closed', 'DATA-001',
        1003, '2026-09-22', '2026-09-03',
        '2027-01-01', 'Contract', 0,
        'Pending', 'OPP003', 1002
    ),

    (
        999, 'Unknown Company', 'HC999',
        'Software Engineer', '2026-10-15',
        NULL,
        'Yes', '12:00',
        NULL,
        'No', 'India', NULL, NULL, NULL,
        NULL, 1, 'Open', 'ENG-999',
        1004, '2026-09-23', '2026-09-04',
        NULL, 'Contract', 0,
        'Failed', 'OPP999', 1003
    );


/* ============================================================
   9. JobCustomObject
   ============================================================ */

INSERT INTO dbo.JobCustomObject
(
    id,
    JobID,
    SF_Opp_ID,
    EngagementCode,
    EngagementName,
    RepliconProjectID,
    LastModifiedUser,
    LastModifiedDate,
    EDWAuditID
)
VALUES
    (
        1, 1001, 'OPP001',
        'ENG001', 'Acme Data Project',
        'REP001', 'Amit Sharma',
        '2026-09-20', 1001
    ),

    (
        2, 1002, 'OPP002',
        'ENG002', 'Global QA Project',
        'REP002', 'Neha Reddy',
        '2026-09-21', 1001
    ),

    (
        3, 9999, 'OPP999',
        'ENG999', 'Invalid Job Reference',
        'REP999', 'John Thomas',
        '2026-09-22', 1002
    );


/* ============================================================
   10. JobSubmission
   ============================================================ */

INSERT INTO dbo.JobSubmission
(
    status,
    jobOrder,
    Title,
    CandidateID,
    FirstName,
    LastName,
    JobResponseID,
    dateLastModified,
    dateAdded,
    IsDeleted,
    EDWAuditID
)
VALUES
    (
        'Submitted', 1001, 'Data Engineer',
        10001, 'Ananya', 'Rao',
        5001, '2026-09-10', '2026-09-10',
        0, 1001
    ),

    (
        'Submitted', 1001, 'Data Engineer',
        10002, 'Rahul', 'Kumar',
        5002, '2026-09-11', '2026-09-11',
        0, 1001
    ),

    (
        'Submitted', 1002, 'QA Engineer',
        10003, 'Priya', 'Sharma',
        5003, '2026-09-12', '2026-09-12',
        0, 1002
    ),

    (
        'Submitted', 9999, 'Invalid Job',
        10001, 'Ananya', 'Rao',
        5004, '2026-09-13', '2026-09-13',
        0, 1002
    ),

    (
        'Submitted', 1002, 'QA Engineer',
        99999, 'Unknown', 'Candidate',
        5005, '2026-09-14', '2026-09-14',
        0, 1003
    );


/* ============================================================
   11. Placement
   ============================================================ */

INSERT INTO dbo.Placement
(
    id,
    candidateID,
    [ConsilioOffice/Location],
    PayRate,
    EngagementNumber,
    PlacementStatus,
    Employment_Type,
    CostCenter,
    BillingContact,
    StartDate,
    ScheduledEnd,
    OverallGrade,
    ReportingTo,
    [Over-TimePayRate],
    EffectiveDate,
    TimesheetMethod,
    ReviewSolutionsVertical,
    CaseTimeNarrativesRequired,
    DateAdded,
    DateLastModified,
    jobOrderID,
    jobSubmissionID,
    SlCAIntegrationPLStatus,
    SlCAIntegrationPLMessage,
    BaseOrg,
    ActualEnd,
    TimeEngagementCodePicker,
    EmploymentStartDate,
    EDWAuditID,
    PayCurrency,
    BillCurrency,
    BillRate,
    BillUnit,
    PayUnit,
    JobTitle,
    PlacedBy,
    correlatedCustomInt1
)
VALUES
    (
        1, 10001, 'Bangalore',
        50000, 'ENG-001', 'Active',
        'Full Time', 'CC001', 1,
        '2026-10-01', NULL, 'A',
        'Manager A', 60000,
        '2026-10-01', 'Electronic',
        'Data', 'Yes',
        '2026-09-20', '2026-09-20',
        1001, 5001,
        'Success', NULL, 'India',
        NULL, 'ENG001', '2026-10-01',
        1001, 'INR', 'INR',
        60000, 1, 'Month',
        'Data Engineer', 'Amit Sharma', 1
    ),

    (
        2, 10002, 'Mumbai',
        45000, 'QA-001', 'Active',
        'Full Time', 'CC002', 2,
        '2026-10-05', NULL, 'B',
        'Manager B', 55000,
        '2026-10-05', 'Electronic',
        'QA', 'Yes',
        '2026-09-21', '2026-09-21',
        1002, 5002,
        'Success', NULL, 'India',
        NULL, 'QA001', '2026-10-05',
        1001, 'INR', 'INR',
        55000, 1, 'Month',
        'QA Engineer', 'Neha Reddy', 2
    ),

    (
        3, 99999, 'Unknown',
        NULL, 'INVALID-001', 'Pending',
        'Contract', NULL, NULL,
        NULL, NULL, NULL,
        NULL, NULL,
        NULL, NULL,
        NULL, NULL,
        '2026-09-25', '2026-09-25',
        9999, 9999,
        'Failed', 'Invalid references',
        'Unknown', NULL, 'INVALID',
        NULL,
        1003, NULL, NULL,
        NULL, NULL, NULL,
        'Unknown', 'Unknown', 999
    );


/* ============================================================
   12. PlacementCustomObject
   ============================================================ */

INSERT INTO dbo.PlacementCustomObject
(
    id,
    PlacementID,
    ServiceLine,
    Task,
    TaskActivity,
    ForeignLanguage,
    PayRate,
    PayEffectiveDate,
    DateCreated,
    DateLastModified,
    GUID,
    SnaplogicSyncStatus,
    EDWAuditID
)
VALUES
    (
        1, 1, 'Data',
        'Data Engineering',
        'Pipeline Development',
        NULL,
        50000,
        '2026-10-01',
        '2026-09-20',
        '2026-09-20',
        'GUID001',
        'Success',
        1001
    ),

    (
        2, 2, 'QA',
        'Testing',
        'Data Validation',
        NULL,
        45000,
        '2026-10-05',
        '2026-09-21',
        '2026-09-21',
        'GUID002',
        'Success',
        1001
    ),

    (
        3, 9999, 'Unknown',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        '2026-09-25',
        '2026-09-25',
        'GUID003',
        'Failed',
        1003
    );