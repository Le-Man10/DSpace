--
-- The contents of this file are subject to the license and copyright
-- detailed in the LICENSE and NOTICE files at the root of the source
-- tree and available online at
--
-- http://www.dspace.org/license/
--

-------------------------------------------------------------------------------------
---- ALTER table cris_layout_field
-------------------------------------------------------------------------------------

ALTER TABLE cris_layout_field DROP COLUMN IF EXISTS style;
ALTER TABLE cris_layout_field ADD COLUMN IF NOT EXISTS row_style CHARACTER VARYING(255);
ALTER TABLE cris_layout_field ADD COLUMN IF NOT EXISTS cell_style CHARACTER VARYING(255);
ALTER TABLE cris_layout_field ADD COLUMN IF NOT EXISTS cell INTEGER NOT NULL DEFAULT 0;

-------------------------------------------------------------------------------------
---- ALTER table cris_layout_field2nested
-------------------------------------------------------------------------------------

ALTER TABLE cris_layout_field2nested DROP COLUMN IF EXISTS label_as_heading;
ALTER TABLE cris_layout_field2nested DROP COLUMN IF EXISTS values_inline;