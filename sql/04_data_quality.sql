/* ============================================================
   EDW DATA QUALITY ANALYZER
   1. TABLE ROW COUNT
   ============================================================ */

SELECT
    'Candidate' AS TableName,
    COUNT(*) AS TotalRows
FROM dbo.Candidate;


/* ============================================================
   2. NULL CHECK - CANDIDATE
   ============================================================ */

SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN Email1 IS NULL THEN 1 ELSE 0 END) AS NullEmail1,
    SUM(CASE WHEN FirstName IS NULL THEN 1 ELSE 0 END) AS NullFirstName,
    SUM(CASE WHEN LastName IS NULL THEN 1 ELSE 0 END) AS NullLastName,
    SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) AS NullStatus
FROM dbo.Candidate;


/* ============================================================
   3. DUPLICATE EMAIL CHECK
   ============================================================ */

SELECT
    Email1,
    COUNT(*) AS Occurrences
FROM dbo.Candidate
WHERE Email1 IS NOT NULL
GROUP BY Email1
HAVING COUNT(*) > 1;

/* ============================================================
   4. PRIMARY KEY DUPLICATE CHECK
   ============================================================ */

SELECT
    CandidateID,
    COUNT(*) AS Occurrences
FROM dbo.Candidate
GROUP BY CandidateID
HAVING COUNT(*) > 1;


/* ============================================================
   5. ORPHAN JOBORDER → COMPANY
   ============================================================ */

SELECT
    j.JobID,
    j.CompanyID,
    j.CompanyName
FROM dbo.JobOrder j
LEFT JOIN dbo.Company c
    ON j.CompanyID = c.id
WHERE
    j.CompanyID IS NOT NULL
    AND c.id IS NULL;


/* ============================================================
   6. ORPHAN JOBSUBMISSION → JOBORDER
   ============================================================ */

SELECT
    js.JobResponseID,
    js.jobOrder,
    js.CandidateID
FROM dbo.JobSubmission js
LEFT JOIN dbo.JobOrder jo
    ON js.jobOrder = jo.JobID
WHERE
    js.jobOrder IS NOT NULL
    AND jo.JobID IS NULL;

/* ============================================================
   7. ORPHAN JOBSUBMISSION → CANDIDATE
   ============================================================ */

SELECT
    js.JobResponseID,
    js.jobOrder,
    js.CandidateID
FROM dbo.JobSubmission js
LEFT JOIN dbo.Candidate c
    ON js.CandidateID = c.CandidateID
WHERE
    js.CandidateID IS NOT NULL
    AND c.CandidateID IS NULL;

/* ============================================================
   8. ORPHAN PLACEMENT → CANDIDATE
   ============================================================ */

SELECT
    p.id AS PlacementID,
    p.candidateID,
    p.jobOrderID
FROM dbo.Placement p
LEFT JOIN dbo.Candidate c
    ON p.candidateID = c.CandidateID
WHERE
    p.candidateID IS NOT NULL
    AND c.CandidateID IS NULL;

/* ============================================================
   9. ORPHAN PLACEMENT → JOBORDER
   ============================================================ */

SELECT
    p.id AS PlacementID,
    p.jobOrderID,
    p.candidateID
FROM dbo.Placement p
LEFT JOIN dbo.JobOrder j
    ON p.jobOrderID = j.JobID
WHERE
    p.jobOrderID IS NOT NULL
    AND j.JobID IS NULL;

/* ============================================================
   10. ORPHAN PLACEMENT CUSTOM OBJECT
   ============================================================ */

SELECT
    pco.id AS PlacementCustomObjectID,
    pco.PlacementID
FROM dbo.PlacementCustomObject pco
LEFT JOIN dbo.Placement p
    ON pco.PlacementID = p.id
WHERE
    pco.PlacementID IS NOT NULL
    AND p.id IS NULL;