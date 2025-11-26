// Neo4j Structured Data Load Script
// Loads Asset_Manager_Holdings.csv and Company_Filings.csv
// Creates: AssetManager, Company, Document nodes
// Creates: OWNS, FILED relationships

// ============================================
// STEP 1: Create constraints for unique keys
// ============================================

CREATE CONSTRAINT asset_manager_name IF NOT EXISTS
FOR (a:AssetManager) REQUIRE a.managerName IS UNIQUE;

CREATE CONSTRAINT company_name IF NOT EXISTS
FOR (c:Company) REQUIRE c.name IS UNIQUE;

CREATE CONSTRAINT document_path IF NOT EXISTS
FOR (d:Document) REQUIRE d.path IS UNIQUE;

// ============================================
// STEP 2: Load Company nodes from Company_Filings.csv
// ============================================

LOAD CSV WITH HEADERS FROM $companyFilingsUrl AS row
MERGE (c:Company {name: row.name})
SET c.ticker = row.ticker;

// ============================================
// STEP 3: Load Document nodes from Company_Filings.csv
// ============================================

LOAD CSV WITH HEADERS FROM $companyFilingsUrl AS row
MERGE (d:Document {path: row.path_Mac_ix});

// ============================================
// STEP 4: Load AssetManager nodes from Asset_Manager_Holdings.csv
// ============================================

LOAD CSV WITH HEADERS FROM $assetManagerUrl AS row
MERGE (a:AssetManager {managerName: row.managerName});

// ============================================
// STEP 5: Create FILED relationships (Company -> Document)
// ============================================

LOAD CSV WITH HEADERS FROM $companyFilingsUrl AS row
MATCH (c:Company {name: row.name})
MATCH (d:Document {path: row.path_Mac_ix})
MERGE (c)-[:FILED]->(d);

// ============================================
// STEP 6: Create OWNS relationships (AssetManager -> Company)
// ============================================

LOAD CSV WITH HEADERS FROM $assetManagerUrl AS row
MATCH (a:AssetManager {managerName: row.managerName})
MATCH (c:Company {name: row.companyName})
MERGE (a)-[r:OWNS]->(c)
SET r.shares = toInteger(row.shares);
