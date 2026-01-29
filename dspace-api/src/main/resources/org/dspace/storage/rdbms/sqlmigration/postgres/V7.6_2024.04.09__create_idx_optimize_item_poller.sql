--
-- The contents of this file are subject to the license and copyright
-- detailed in the LICENSE and NOTICE files at the root of the source
-- tree and available online at
--
-- http://www.dspace.org/license/
--

-----------------------------------------------------------------------------------
-- Create INDEXES to optimize exact query over the metadatavalue
-----------------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_text_value_hash ON metadatavalue (substring(text_value,1,36));
CREATE INDEX IF NOT EXISTS idx_authority_hash ON metadatavalue (authority);