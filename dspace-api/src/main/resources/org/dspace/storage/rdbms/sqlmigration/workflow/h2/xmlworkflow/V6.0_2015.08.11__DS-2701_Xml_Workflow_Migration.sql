--
-- The contents of this file are subject to the license and copyright
-- detailed in the LICENSE and NOTICE files at the root of the source
-- tree and available online at
--
-- http://www.dspace.org/license/
--

------------------------------------------------------
-- DS-2701 Service based API / Hibernate integration
------------------------------------------------------
UPDATE collection SET workflow_step_1 = null;
UPDATE collection SET workflow_step_2 = null;
UPDATE collection SET workflow_step_3 = null;

-- cwf_workflowitem

DROP INDEX IF EXISTS cwf_workflowitem_coll_fk_idx;

ALTER TABLE cwf_workflowitem ALTER COLUMN item_id RENAME TO item_legacy_id;
ALTER TABLE cwf_workflowitem ADD COLUMN IF NOT EXISTS item_id UUID;
ALTER TABLE cwf_workflowitem ADD FOREIGN KEY (item_id) REFERENCES Item(uuid);
UPDATE cwf_workflowitem SET item_id = (SELECT item.uuid FROM item WHERE cwf_workflowitem.item_legacy_id = item.item_id);
ALTER TABLE cwf_workflowitem DROP COLUMN IF EXISTS item_legacy_id;

ALTER TABLE cwf_workflowitem ALTER COLUMN collection_id RENAME TO collection_legacy_id;
ALTER TABLE cwf_workflowitem ADD COLUMN IF NOT EXISTS collection_id UUID;
ALTER TABLE cwf_workflowitem ADD FOREIGN KEY (collection_id) REFERENCES Collection(uuid);
UPDATE cwf_workflowitem SET collection_id = (SELECT collection.uuid FROM collection WHERE cwf_workflowitem.collection_legacy_id = collection.collection_id);
ALTER TABLE cwf_workflowitem DROP COLUMN IF EXISTS collection_legacy_id;

UPDATE cwf_workflowitem SET multiple_titles = '0' WHERE multiple_titles IS NULL;
UPDATE cwf_workflowitem SET published_before = '0' WHERE published_before IS NULL;
UPDATE cwf_workflowitem SET multiple_files = '0' WHERE multiple_files IS NULL;

CREATE INDEX IF NOT EXISTS cwf_workflowitem_coll_fk_idx ON cwf_workflowitem(collection_id);

-- cwf_collectionrole

ALTER TABLE cwf_collectionrole DROP CONSTRAINT IF EXISTS cwf_collectionrole_unique;
DROP INDEX IF EXISTS cwf_cr_coll_role_fk_idx;
DROP INDEX IF EXISTS cwf_cr_coll_fk_idx;

ALTER TABLE cwf_collectionrole ALTER COLUMN collection_id RENAME TO collection_legacy_id;
ALTER TABLE cwf_collectionrole ADD COLUMN IF NOT EXISTS collection_id UUID;
ALTER TABLE cwf_collectionrole ADD FOREIGN KEY (collection_id) REFERENCES Collection(uuid);
UPDATE cwf_collectionrole SET collection_id = (SELECT collection.uuid FROM collection WHERE cwf_collectionrole.collection_legacy_id = collection.collection_id);
ALTER TABLE cwf_collectionrole DROP COLUMN IF EXISTS collection_legacy_id;

ALTER TABLE cwf_collectionrole ALTER COLUMN group_id RENAME TO group_legacy_id;
ALTER TABLE cwf_collectionrole ADD COLUMN IF NOT EXISTS group_id UUID;
ALTER TABLE cwf_collectionrole ADD FOREIGN KEY (group_id) REFERENCES epersongroup(uuid);
UPDATE cwf_collectionrole SET group_id = (SELECT epersongroup.uuid FROM epersongroup WHERE cwf_collectionrole.group_legacy_id = epersongroup.eperson_group_id);
ALTER TABLE cwf_collectionrole DROP COLUMN IF EXISTS group_legacy_id;

ALTER TABLE cwf_collectionrole DROP CONSTRAINT IF EXISTS cwf_collectionrole_unique; ALTER TABLE cwf_collectionrole ADD CONSTRAINT cwf_collectionrole_unique UNIQUE (role_id, collection_id, group_id);

CREATE INDEX IF NOT EXISTS cwf_cr_coll_role_fk_idx ON cwf_collectionrole(collection_id,role_id);
CREATE INDEX IF NOT EXISTS cwf_cr_coll_fk_idx ON cwf_collectionrole(collection_id);


-- cwf_workflowitemrole

ALTER TABLE cwf_workflowitemrole DROP CONSTRAINT IF EXISTS cwf_workflowitemrole_unique;
DROP INDEX IF EXISTS cwf_wfir_item_role_fk_idx;
DROP INDEX IF EXISTS cwf_wfir_item_fk_idx;

ALTER TABLE cwf_workflowitemrole ALTER COLUMN group_id RENAME TO group_legacy_id;
ALTER TABLE cwf_workflowitemrole ADD COLUMN IF NOT EXISTS group_id UUID;
ALTER TABLE cwf_workflowitemrole ADD FOREIGN KEY (group_id) REFERENCES epersongroup(uuid);
UPDATE cwf_workflowitemrole SET group_id = (SELECT epersongroup.uuid FROM epersongroup WHERE cwf_workflowitemrole.group_legacy_id = epersongroup.eperson_group_id);
ALTER TABLE cwf_workflowitemrole DROP COLUMN IF EXISTS group_legacy_id;

ALTER TABLE cwf_workflowitemrole ALTER COLUMN eperson_id RENAME TO eperson_legacy_id;
ALTER TABLE cwf_workflowitemrole ADD COLUMN IF NOT EXISTS eperson_id UUID;
ALTER TABLE cwf_workflowitemrole ADD FOREIGN KEY (eperson_id) REFERENCES eperson(uuid);
UPDATE cwf_workflowitemrole SET eperson_id = (SELECT eperson.uuid FROM eperson WHERE cwf_workflowitemrole.eperson_legacy_id = eperson.eperson_id);
ALTER TABLE cwf_workflowitemrole DROP COLUMN IF EXISTS eperson_legacy_id;


ALTER TABLE cwf_workflowitemrole DROP CONSTRAINT IF EXISTS cwf_workflowitemrole_unique; ALTER TABLE cwf_workflowitemrole ADD CONSTRAINT cwf_workflowitemrole_unique UNIQUE (role_id, workflowitem_id, eperson_id, group_id);

CREATE INDEX IF NOT EXISTS cwf_wfir_item_role_fk_idx ON cwf_workflowitemrole(workflowitem_id,role_id);
CREATE INDEX IF NOT EXISTS cwf_wfir_item_fk_idx ON cwf_workflowitemrole(workflowitem_id);

-- cwf_pooltask

DROP INDEX IF EXISTS cwf_pt_eperson_fk_idx;
DROP INDEX IF EXISTS cwf_pt_workflow_eperson_fk_idx;

ALTER TABLE cwf_pooltask ALTER COLUMN group_id RENAME TO group_legacy_id;
ALTER TABLE cwf_pooltask ADD COLUMN IF NOT EXISTS group_id UUID;
ALTER TABLE cwf_pooltask ADD FOREIGN KEY (group_id) REFERENCES epersongroup(uuid);
UPDATE cwf_pooltask SET group_id = (SELECT epersongroup.uuid FROM epersongroup WHERE cwf_pooltask.group_legacy_id = epersongroup.eperson_group_id);
ALTER TABLE cwf_pooltask DROP COLUMN IF EXISTS group_legacy_id;

ALTER TABLE cwf_pooltask ALTER COLUMN eperson_id RENAME TO eperson_legacy_id;
ALTER TABLE cwf_pooltask ADD COLUMN IF NOT EXISTS eperson_id UUID;
ALTER TABLE cwf_pooltask ADD FOREIGN KEY (eperson_id) REFERENCES eperson(uuid);
UPDATE cwf_pooltask SET eperson_id = (SELECT eperson.uuid FROM eperson WHERE cwf_pooltask.eperson_legacy_id = eperson.eperson_id);
ALTER TABLE cwf_pooltask DROP COLUMN IF EXISTS eperson_legacy_id;

CREATE INDEX IF NOT EXISTS cwf_pt_eperson_fk_idx ON cwf_pooltask(eperson_id);
CREATE INDEX IF NOT EXISTS cwf_pt_workflow_eperson_fk_idx ON cwf_pooltask(eperson_id,workflowitem_id);

-- cwf_claimtask

ALTER TABLE cwf_claimtask DROP CONSTRAINT IF EXISTS cwf_claimtask_unique;
DROP INDEX IF EXISTS cwf_ct_workflow_fk_idx;
DROP INDEX IF EXISTS cwf_ct_workflow_eperson_fk_idx;
DROP INDEX IF EXISTS cwf_ct_eperson_fk_idx;
DROP INDEX IF EXISTS cwf_ct_wfs_fk_idx;
DROP INDEX IF EXISTS cwf_ct_wfs_action_fk_idx;
DROP INDEX IF EXISTS cwf_ct_wfs_action_e_fk_idx;

ALTER TABLE cwf_claimtask ALTER COLUMN owner_id RENAME TO eperson_legacy_id;
ALTER TABLE cwf_claimtask ADD COLUMN IF NOT EXISTS owner_id UUID;
ALTER TABLE cwf_claimtask ADD FOREIGN KEY (owner_id) REFERENCES eperson(uuid);

UPDATE cwf_claimtask SET owner_id = (SELECT eperson.uuid FROM eperson WHERE cwf_claimtask.eperson_legacy_id = eperson.eperson_id);
ALTER TABLE cwf_claimtask DROP COLUMN IF EXISTS eperson_legacy_id;

ALTER TABLE cwf_claimtask DROP CONSTRAINT IF EXISTS cwf_claimtask_unique; ALTER TABLE cwf_claimtask ADD CONSTRAINT cwf_claimtask_unique UNIQUE (step_id, workflowitem_id, workflow_id, owner_id, action_id);

CREATE INDEX IF NOT EXISTS cwf_ct_workflow_fk_idx ON cwf_claimtask(workflowitem_id);
CREATE INDEX IF NOT EXISTS cwf_ct_workflow_eperson_fk_idx ON cwf_claimtask(workflowitem_id,owner_id);
CREATE INDEX IF NOT EXISTS cwf_ct_eperson_fk_idx ON cwf_claimtask(owner_id);
CREATE INDEX IF NOT EXISTS cwf_ct_wfs_fk_idx ON cwf_claimtask(workflowitem_id,step_id);
CREATE INDEX IF NOT EXISTS cwf_ct_wfs_action_fk_idx ON cwf_claimtask(workflowitem_id,step_id,action_id);
CREATE INDEX IF NOT EXISTS cwf_ct_wfs_action_e_fk_idx ON cwf_claimtask(workflowitem_id,step_id,action_id,owner_id);

-- cwf_in_progress_user

ALTER TABLE cwf_in_progress_user DROP CONSTRAINT IF EXISTS cwf_in_progress_user_unique;
DROP INDEX IF EXISTS cwf_ipu_workflow_fk_idx;
DROP INDEX IF EXISTS cwf_ipu_eperson_fk_idx;

ALTER TABLE cwf_in_progress_user ALTER COLUMN user_id RENAME TO eperson_legacy_id;
ALTER TABLE cwf_in_progress_user ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE cwf_in_progress_user ADD FOREIGN KEY (user_id) REFERENCES eperson(uuid);
UPDATE cwf_in_progress_user SET user_id = (SELECT eperson.uuid FROM eperson WHERE cwf_in_progress_user.eperson_legacy_id = eperson.eperson_id);
ALTER TABLE cwf_in_progress_user DROP COLUMN IF EXISTS eperson_legacy_id;
UPDATE cwf_in_progress_user SET finished = '0' WHERE finished IS NULL;

ALTER TABLE cwf_in_progress_user DROP CONSTRAINT IF EXISTS cwf_in_progress_user_unique; ALTER TABLE cwf_in_progress_user ADD CONSTRAINT cwf_in_progress_user_unique UNIQUE (workflowitem_id, user_id);

CREATE INDEX IF NOT EXISTS cwf_ipu_workflow_fk_idx ON cwf_in_progress_user(workflowitem_id);
CREATE INDEX IF NOT EXISTS cwf_ipu_eperson_fk_idx ON cwf_in_progress_user(user_id);