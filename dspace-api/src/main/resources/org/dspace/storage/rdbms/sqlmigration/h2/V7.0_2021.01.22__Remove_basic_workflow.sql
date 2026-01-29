--
-- The contents of this file are subject to the license and copyright
-- detailed in the LICENSE and NOTICE files at the root of the source
-- tree and available online at
--
-- http://www.dspace.org/license/
--

-----------------------------------------------------------------------------------
-- Drop the 'workflowitem' and 'tasklistitem' tables
-----------------------------------------------------------------------------------

DROP TABLE IF EXISTS workflowitem CASCADE CONSTRAINTS;
DROP TABLE IF EXISTS tasklistitem CASCADE CONSTRAINTS;

DROP SEQUENCE IF EXISTS workflowitem_seq;
DROP SEQUENCE IF EXISTS tasklistitem_seq;