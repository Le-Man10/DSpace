--
-- The contents of this file are subject to the license and copyright
-- detailed in the LICENSE and NOTICE files at the root of the source
-- tree and available online at
--
-- http://www.dspace.org/license/
--

ALTER TABLE orcid_queue ADD COLUMN IF NOT EXISTS put_code VARCHAR(255);
ALTER TABLE orcid_queue ADD COLUMN IF NOT EXISTS record_type VARCHAR(255);
ALTER TABLE orcid_queue ADD COLUMN IF NOT EXISTS description VARCHAR(255);
ALTER TABLE orcid_queue ADD COLUMN IF NOT EXISTS operation VARCHAR(255);
ALTER TABLE orcid_queue ADD COLUMN IF NOT EXISTS metadata CLOB;

ALTER TABLE orcid_queue ALTER COLUMN entity_id SET NULL;

ALTER TABLE orcid_history ADD COLUMN IF NOT EXISTS metadata CLOB;
ALTER TABLE orcid_history ADD COLUMN IF NOT EXISTS operation VARCHAR(255);
ALTER TABLE orcid_history ADD COLUMN IF NOT EXISTS record_type VARCHAR(255);
ALTER TABLE orcid_history ADD COLUMN IF NOT EXISTS description VARCHAR(255);

ALTER TABLE orcid_history DROP COLUMN IF EXISTS timestamp_success_attempt;

ALTER TABLE orcid_history ALTER COLUMN entity_id SET NULL;