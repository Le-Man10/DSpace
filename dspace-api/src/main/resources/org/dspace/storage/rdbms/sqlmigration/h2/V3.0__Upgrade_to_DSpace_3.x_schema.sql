--
-- The contents of this file are subject to the license and copyright
-- detailed in the LICENSE and NOTICE files at the root of the source
-- tree and available online at
--
-- http://www.dspace.org/license/
--

-- ===============================================================
-- WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
--
-- DO NOT MANUALLY RUN THIS DATABASE MIGRATION. IT WILL BE EXECUTED
-- AUTOMATICALLY (IF NEEDED) BY "FLYWAY" WHEN YOU STARTUP DSPACE.
-- http://flywaydb.org/
-- ===============================================================

ALTER TABLE resourcepolicy ADD COLUMN IF NOT EXISTS rpname VARCHAR2(30);
ALTER TABLE resourcepolicy ADD COLUMN IF NOT EXISTS rptype VARCHAR2(30);
ALTER TABLE resourcepolicy ADD COLUMN IF NOT EXISTS rpdescription VARCHAR2(100);


ALTER TABLE item ADD COLUMN IF NOT EXISTS discoverable BOOLEAN;

CREATE TABLE IF NOT EXISTS versionhistory
(
  versionhistory_id INTEGER NOT NULL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS versionitem
(
  versionitem_id INTEGER NOT NULL PRIMARY KEY,
  item_id INTEGER REFERENCES Item(item_id),
  version_number INTEGER,
  eperson_id INTEGER REFERENCES EPerson(eperson_id),
  version_date TIMESTAMP,
  version_summary VARCHAR2(255),
  versionhistory_id INTEGER REFERENCES VersionHistory(versionhistory_id)
);

CREATE SEQUENCE IF NOT EXISTS versionitem_seq;
CREATE SEQUENCE IF NOT EXISTS versionhistory_seq;


-------------------------------------------
-- New columns and longer hash for salted password hashing DS-861 --
-------------------------------------------
ALTER TABLE EPerson ALTER COLUMN password VARCHAR(128);
ALTER TABLE EPerson ADD COLUMN IF NOT EXISTS salt VARCHAR(32);
ALTER TABLE EPerson ADD COLUMN IF NOT EXISTS digest_algorithm VARCHAR(16);
