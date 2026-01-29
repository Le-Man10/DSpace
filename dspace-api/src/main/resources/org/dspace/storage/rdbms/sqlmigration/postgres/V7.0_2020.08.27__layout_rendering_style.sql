--
-- The contents of this file are subject to the license and copyright
-- detailed in the LICENSE and NOTICE files at the root of the source
-- tree and available online at
--
-- http://www.dspace.org/license/
--

ALTER TABLE cris_layout_field ADD COLUMN IF NOT EXISTS style_label VARCHAR(255);

ALTER TABLE cris_layout_field ADD COLUMN IF NOT EXISTS style_value VARCHAR(255);