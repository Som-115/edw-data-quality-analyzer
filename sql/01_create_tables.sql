/* ============================================================
   Ingest_Bullhorn - EDW Prototype Database
   Purpose:
   Personal prototype for EDW Data Quality / Investigation tool

   Source:
   Ingest_Bullhorn metadata

   Removed from prototype:
   - Candidate_Notes       (no declared PK)
   - JobOrderCustomObject  (no declared PK)

   Note:
   dbo.EDWAudit is a prototype stand-in for the real
   external EDWAdmin.EDWAudit table.
   ============================================================ */


/* ============================================================
   1. EDWAudit - Prototype Parent Table
   ============================================================ */

CREATE TABLE dbo.EDWAudit
(
    EDWAuditID BIGINT NOT NULL,
    CONSTRAINT PK_EDWAudit
        PRIMARY KEY (EDWAuditID)
);


/* ============================================================
   2. Candidate
   ============================================================ */

CREATE TABLE dbo.Candidate
(
    Email1 VARCHAR(255) NULL,
    FirstName VARCHAR(255) NULL,
    LastName VARCHAR(255) NULL,
    UKGBaseRate VARCHAR(255) NULL,
    BarStatus VARCHAR(255) NULL,
    ConsilioServicesRole VARCHAR(255) NULL,
    Ultipro# VARCHAR(255) NULL,
    Payroll VARCHAR(255) NULL,

    CandidateID INT NOT NULL,

    EMAIL3 VARCHAR(255) NULL,
    Email2 VARCHAR(255) NULL,
    status VARCHAR(255) NULL,
    DateAdded DATETIME NULL,
    DateLastModified DATETIME NULL,
    OwnerID INT NULL,
    OwnerFirstName VARCHAR(255) NULL,
    OwnerLastName VARCHAR(255) NULL,
    CountryID INT NULL,
    IsDeleted INT NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_Candidate_CandidateID
        PRIMARY KEY (CandidateID),

    CONSTRAINT FK_Candidate_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   3. Candidate_Files
   ============================================================ */

CREATE TABLE dbo.Candidate_Files
(
    id INT NOT NULL,
    contentSubType VARCHAR(255) NULL,
    contentType VARCHAR(255) NULL,
    dateAdded DATETIME NULL,
    description VARCHAR(MAX) NULL,
    directory VARCHAR(255) NULL,
    distribution VARCHAR(255) NULL,
    externalID VARCHAR(150) NULL,
    fileExtension VARCHAR(100) NULL,
    fileSize INT NULL,
    fileType VARCHAR(100) NULL,
    isCopied BIT NULL,
    isDeleted BIT NULL,
    isOpen BIT NULL,
    isPrivate BIT NULL,
    isSendOut BIT NULL,
    CandidateID BIGINT NULL,
    firstName VARCHAR(255) NULL,
    lastName VARCHAR(255) NULL,
    name VARCHAR(255) NULL,
    type VARCHAR(200) NULL,
    uuid VARCHAR(255) NULL,

    CONSTRAINT PK_Candidate_Files_id
        PRIMARY KEY (id)
);


/* ============================================================
   4. CandidateEducation
   ============================================================ */

CREATE TABLE dbo.CandidateEducation
(
    id INT NOT NULL,
    candidateid INT NULL,
    firstName VARCHAR(255) NULL,
    lastName VARCHAR(255) NULL,
    certification VARCHAR(255) NULL,
    city VARCHAR(255) NULL,
    comments VARCHAR(MAX) NULL,
    VerifiedDate DATETIME NULL,
    VerifiedBy VARCHAR(255) NULL,
    dateAdded DATETIME NULL,
    dateLastModified DATETIME NULL,
    degree VARCHAR(255) NULL,
    endDate DATETIME NULL,
    expirationDate DATETIME NULL,
    gpa FLOAT NULL,
    graduationDate DATETIME NULL,
    isDeleted INT NULL,
    major VARCHAR(255) NULL,
    school VARCHAR(255) NULL,
    startDate DATETIME NULL,
    state VARCHAR(255) NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_CandidateEducation_id
        PRIMARY KEY (id),

    CONSTRAINT FK_CandidateEducation_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   5. CandidateReference
   ============================================================ */

CREATE TABLE dbo.CandidateReference
(
    ID INT NOT NULL,
    candidateID INT NULL,
    FirstName VARCHAR(255) NULL,
    LastName VARCHAR(255) NULL,
    CandidateTitle VARCHAR(255) NULL,
    ClientCorporationID INT NULL,
    Name VARCHAR(255) NULL,
    CompanyName VARCHAR(255) NULL,
    ReferenceDetails VARCHAR(MAX) NULL,
    DateAdded DATETIME NULL,
    DateLastModified DATETIME NULL,
    EmploymentEnd DATETIME NULL,
    EmploymentStart DATETIME NULL,
    JobID INT NULL,
    Title VARCHAR(255) NULL,
    ReferenceClientContactID INT NULL,
    ClientContact_FirstName VARCHAR(255) NULL,
    ClientContact_LastName VARCHAR(255) NULL,
    ReferenceEmail VARCHAR(255) NULL,
    ReferenceFirstName VARCHAR(255) NULL,
    ReferenceLastName VARCHAR(255) NULL,
    ReferencePhone VARCHAR(255) NULL,
    ReferenceTitle VARCHAR(255) NULL,
    Status VARCHAR(255) NULL,
    YearsKnown VARCHAR(255) NULL,
    IsDeleted INT NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_CandidateReference_ID
        PRIMARY KEY (ID),

    CONSTRAINT FK_CandidateReference_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   6. CandidateReferenceClientContact
   ============================================================ */

CREATE TABLE dbo.CandidateReferenceClientContact
(
    ID INT NOT NULL,
    ClientContactReferenceID INT NULL,
    ClientContact_FirstName VARCHAR(255) NULL,
    ClientContact_LastName VARCHAR(255) NULL,
    IsDeleted INT NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_CandidateReferenceClientContact_ID
        PRIMARY KEY (ID),

    CONSTRAINT FK_CandidateReferenceClientContact_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   7. CandidateWorkHistory
   ============================================================ */

CREATE TABLE dbo.CandidateWorkHistory
(
    ID INT NOT NULL,
    Bonus FLOAT NULL,
    CandidateID INT NULL,
    FirstName VARCHAR(255) NULL,
    LastName VARCHAR(255) NULL,
    ClientCorporationID INT NULL,
    ClientCorporationName VARCHAR(255) NULL,
    Comments VARCHAR(MAX) NULL,
    Commission FLOAT NULL,
    CompanyName VARCHAR(255) NULL,
    DateAdded DATETIME NULL,
    DateLastModified DATETIME NULL,
    IsDeleted INT NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_CandidateWorkHistory_ID
        PRIMARY KEY (ID),

    CONSTRAINT FK_CandidateWorkHistory_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   8. ClientContact
   ============================================================ */

CREATE TABLE dbo.ClientContact
(
    ID VARCHAR(255) NOT NULL,
    FirstName VARCHAR(255) NULL,
    LastName VARCHAR(255) NULL,
    ADUsername VARCHAR(255) NULL,
    AD_GUID VARCHAR(255) NULL,
    Email VARCHAR(255) NULL,
    ADEmail VARCHAR(255) NULL,
    DateLastModified DATETIME NULL,
    DateAdded DATETIME NULL,
    isDeleted VARCHAR(255) NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_ClientContact_ID
        PRIMARY KEY (ID),

    CONSTRAINT FK_ClientContact_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   9. Company
   ============================================================ */

CREATE TABLE dbo.Company
(
    id INT NOT NULL,
    OperationsManager VARCHAR(255) NULL,
    Salesforceid VARCHAR(200) NULL,
    status VARCHAR(200) NULL,
    CompanyName VARCHAR(255) NULL,
    companyURL VARCHAR(255) NULL,
    Ownership VARCHAR(255) NULL,
    YearFounded VARCHAR(100) NULL,
    CompanyDescription VARCHAR(MAX) NULL,
    Phone VARCHAR(255) NULL,
    Fax VARCHAR(255) NULL,
    Address VARCHAR(255) NULL,
    Address2 VARCHAR(255) NULL,
    City VARCHAR(100) NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_Company_id
        PRIMARY KEY (id),

    CONSTRAINT FK_Company_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   10. CorporateUser
   ============================================================ */

CREATE TABLE dbo.CorporateUser
(
    id INT NOT NULL,
    isHidden VARCHAR(30) NULL,
    isLockedOut VARCHAR(30) NULL,
    lastName VARCHAR(255) NULL,
    middleName VARCHAR(255) NULL,
    mobile VARCHAR(255) NULL,
    name VARCHAR(255) NULL,
    namePrefix VARCHAR(255) NULL,
    nameSuffix VARCHAR(255) NULL,
    nickName VARCHAR(255) NULL,
    occupation VARCHAR(255) NULL,
    phone VARCHAR(255) NULL,
    primaryDepartmentID INT NULL,
    primaryDepartmentName VARCHAR(255) NULL,
    reportToPersonID INT NULL,
    status VARCHAR(200) NULL,
    userDateAdded DATETIME NULL,
    userTypeID INT NULL,
    UserTypeName VARCHAR(200) NULL,
    username VARCHAR(255) NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_CorporateUser_id
        PRIMARY KEY (id),

    CONSTRAINT FK_CorporateUser_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   11. Country
   ============================================================ */

CREATE TABLE dbo.Country
(
    id INT NOT NULL,
    Name VARCHAR(255) NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_Country_id
        PRIMARY KEY (id),

    CONSTRAINT FK_Country_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   12. JobCustomObject
   ============================================================ */

CREATE TABLE dbo.JobCustomObject
(
    id INT NOT NULL,
    JobID INT NULL,
    SF_Opp_ID NVARCHAR(40) NULL,
    EngagementCode VARCHAR(50) NULL,
    EngagementName VARCHAR(100) NULL,
    RepliconProjectID VARCHAR(50) NULL,
    LastModifiedUser VARCHAR(50) NULL,
    LastModifiedDate DATETIME NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_JobCustomObject_id
        PRIMARY KEY (id),

    CONSTRAINT FK_JobCustomObject_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   13. JobOrder
   ============================================================ */

CREATE TABLE dbo.JobOrder
(
    CompanyID INT NULL,
    CompanyName VARCHAR(255) NULL,
    Hcode VARCHAR(100) NULL,
    Jobtitle VARCHAR(255) NULL,
    StartDate DATETIME NULL,
    RMEmailAddress VARCHAR(300) NULL,
    ReadyforStaffingRequest VARCHAR(255) NULL,
    ProjectStartTime VARCHAR(255) NULL,
    ExternalPlatformURL VARCHAR(1500) NULL,
    InternallyHosted VARCHAR(100) NULL,
    PlatformGeography VARCHAR(255) NULL,
    RelativityServer VARCHAR(255) NULL,
    RelativityWorkspace VARCHAR(255) NULL,
    RelativitySecurityGroup VARCHAR(100) NULL,
    [W365/SVR] VARCHAR(255) NULL,
    [Open/Closed] BIT NULL,
    Status VARCHAR(100) NULL,
    EngagementNumber VARCHAR(MAX) NULL,
    JobID INT NOT NULL,
    LastModifiedDate DATETIME NULL,
    DateAdded DATETIME NULL,
    ScheduledEndDate DATETIME NULL,
    EmploymentType VARCHAR(100) NULL,
    IsDeleted INT NULL,
    SlTAIntegrationStatus VARCHAR(255) NULL,
    SF_Opp_ID VARCHAR(8000) NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_JobOrder_JobID
        PRIMARY KEY (JobID),

    CONSTRAINT FK_JobOrder_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   14. JobSubmission
   ============================================================ */

CREATE TABLE dbo.JobSubmission
(
    status VARCHAR(50) NULL,
    jobOrder INT NULL,
    Title VARCHAR(255) NULL,
    CandidateID INT NULL,
    FirstName VARCHAR(255) NULL,
    LastName VARCHAR(255) NULL,
    JobResponseID BIGINT NOT NULL,
    dateLastModified DATETIME NULL,
    dateAdded DATETIME NULL,
    IsDeleted INT NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_JobSubmission_JobResponseID
        PRIMARY KEY (JobResponseID),

    CONSTRAINT FK_JobSubmission_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   15. PersonCustomObjectInstance1
   ============================================================ */

CREATE TABLE dbo.PersonCustomObjectInstance1
(
    id INT NOT NULL,
    text1 VARCHAR(100) NULL,
    text2 VARCHAR(100) NULL,
    text3 VARCHAR(100) NULL,
    text4 VARCHAR(100) NULL,
    text5 VARCHAR(100) NULL,
    text6 VARCHAR(100) NULL,
    text7 VARCHAR(100) NULL,
    text8 VARCHAR(100) NULL,
    text9 VARCHAR(100) NULL,
    text20 VARCHAR(100) NULL,
    textBlock1 VARCHAR(MAX) NULL,
    date1 BIGINT NULL,
    date2 BIGINT NULL,
    date3 BIGINT NULL,
    dateAdded BIGINT NULL,
    dateLastModified BIGINT NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_PersonCustomObjectInstance1_id
        PRIMARY KEY (id),

    CONSTRAINT FK_PersonCustomObjectInstance1_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   16. PersonCustomObjectInstance3
   ============================================================ */

CREATE TABLE dbo.PersonCustomObjectInstance3
(
    id INT NOT NULL,
    text1 VARCHAR(100) NULL,
    text2 VARCHAR(100) NULL,
    text3 VARCHAR(100) NULL,
    text4 VARCHAR(100) NULL,
    text5 VARCHAR(100) NULL,
    text6 VARCHAR(100) NULL,
    text7 VARCHAR(100) NULL,
    textBlock1 VARCHAR(MAX) NULL,
    textBlock2 VARCHAR(MAX) NULL,
    textBlock3 VARCHAR(MAX) NULL,
    textBlock4 VARCHAR(MAX) NULL,
    dateAdded BIGINT NULL,
    dateLastModified BIGINT NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_PersonCustomObjectInstance3_id
        PRIMARY KEY (id),

    CONSTRAINT FK_PersonCustomObjectInstance3_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   17. Placement
   ============================================================ */

CREATE TABLE dbo.Placement
(
    id INT NOT NULL,
    candidateID INT NULL,
    [ConsilioOffice/Location] VARCHAR(100) NULL,
    PayRate FLOAT NULL,
    EngagementNumber VARCHAR(MAX) NULL,
    PlacementStatus VARCHAR(30) NULL,
    Employment_Type VARCHAR(200) NULL,
    CostCenter VARCHAR(100) NULL,
    BillingContact INT NULL,
    StartDate DATETIME NULL,
    ScheduledEnd DATETIME NULL,
    OverallGrade VARCHAR(100) NULL,
    ReportingTo VARCHAR(100) NULL,
    [Over-TimePayRate] FLOAT NULL,
    EffectiveDate DATETIME NULL,
    TimesheetMethod VARCHAR(100) NULL,
    ReviewSolutionsVertical VARCHAR(100) NULL,
    CaseTimeNarrativesRequired VARCHAR(100) NULL,
    DateAdded DATETIME NULL,
    DateLastModified DATETIME NULL,
    jobOrderID INT NULL,
    jobSubmissionID INT NULL,
    SlCAIntegrationPLStatus VARCHAR(100) NULL,
    SlCAIntegrationPLMessage VARCHAR(100) NULL,
    BaseOrg VARCHAR(100) NULL,
    ActualEnd VARCHAR(255) NULL,
    TimeEngagementCodePicker VARCHAR(MAX) NULL,
    EmploymentStartDate VARCHAR(255) NULL,
    EDWAuditID BIGINT NOT NULL,
    PayCurrency VARCHAR(100) NULL,
    BillCurrency VARCHAR(100) NULL,
    BillRate FLOAT NULL,
    BillUnit INT NULL,
    PayUnit VARCHAR(20) NULL,
    JobTitle VARCHAR(100) NULL,
    PlacedBy VARCHAR(100) NULL,
    correlatedCustomInt1 INT NULL,

    CONSTRAINT PK_Placement_id
        PRIMARY KEY (id),

    CONSTRAINT FK_Placement_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);


/* ============================================================
   18. PlacementCustomObject
   ============================================================ */

CREATE TABLE dbo.PlacementCustomObject
(
    id INT NOT NULL,
    PlacementID INT NULL,
    ServiceLine VARCHAR(50) NULL,
    Task VARCHAR(2500) NULL,
    TaskActivity VARCHAR(550) NULL,
    ForeignLanguage VARCHAR(350) NULL,
    PayRate FLOAT NULL,
    PayEffectiveDate DATETIME NULL,
    DateCreated DATETIME NULL,
    DateLastModified DATETIME NULL,
    GUID VARCHAR(10) NULL,
    SnaplogicSyncStatus VARCHAR(20) NULL,
    EDWAuditID BIGINT NOT NULL,

    CONSTRAINT PK_PlacementCustomObject_id
        PRIMARY KEY (id),

    CONSTRAINT FK_PlacementCustomObject_EDWAudit_EDWAuditID
        FOREIGN KEY (EDWAuditID)
        REFERENCES dbo.EDWAudit(EDWAuditID)
);