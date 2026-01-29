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
--
--   DSpace SQL schema
--
--   Authors:   Peter Breton, Robert Tansley, David Stuve, Daniel Chudnov
--
--   This file is used as-is to initialize a database. Therefore,
--   table and view definitions must be ordered correctly.
--
--   Caution: THIS IS POSTGRESQL-SPECIFIC:
--
--   * SEQUENCES are used for automatic ID generation
--   * FUNCTION getnextid used for automatic ID generation
--
--
--   To convert to work with another database, you need to ensure
--   an SQL function 'getnextid', which takes a table name as an
--   argument, will return a safe new ID to use to create a new
--   row in that table.



-------------------------------------------------------
-- Function for obtaining new IDs.
--
--   * The argument is a table name
--   * It returns a new ID safe to use for that table
--
--   The function reads the next value from the sequence
--   'tablename_seq'
-------------------------------------------------------
CREATE FUNCTION getnextid(VARCHAR(40)) RETURNS INTEGER AS
    'SELECT CAST (nextval($1 || ''_seq'') AS INTEGER) AS RESULT;' LANGUAGE SQL;


-------------------------------------------------------
-- Sequences for creating new IDs (primary keys) for
-- tables.  Each table must have a corresponding
-- sequence called 'tablename_seq'.
-------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS bitstreamformatregistry_seq;
CREATE SEQUENCE IF NOT EXISTS fileextension_seq;
CREATE SEQUENCE IF NOT EXISTS bitstream_seq;
CREATE SEQUENCE IF NOT EXISTS eperson_seq;
-- start group sequence at 0, since Anonymous group = 0
CREATE SEQUENCE IF NOT EXISTS epersongroup_seq MINVALUE 0 START WITH 0;
CREATE SEQUENCE IF NOT EXISTS item_seq;
CREATE SEQUENCE IF NOT EXISTS bundle_seq;
CREATE SEQUENCE IF NOT EXISTS item2bundle_seq;
CREATE SEQUENCE IF NOT EXISTS bundle2bitstream_seq;
CREATE SEQUENCE IF NOT EXISTS dctyperegistry_seq;
CREATE SEQUENCE IF NOT EXISTS dcvalue_seq;
CREATE SEQUENCE IF NOT EXISTS community_seq;
CREATE SEQUENCE IF NOT EXISTS collection_seq;
CREATE SEQUENCE IF NOT EXISTS community2collection_seq;
CREATE SEQUENCE IF NOT EXISTS collection2item_seq;
CREATE SEQUENCE IF NOT EXISTS resourcepolicy_seq;
CREATE SEQUENCE IF NOT EXISTS epersongroup2eperson_seq;
CREATE SEQUENCE IF NOT EXISTS handle_seq;
CREATE SEQUENCE IF NOT EXISTS workspaceitem_seq;
CREATE SEQUENCE IF NOT EXISTS workflowitem_seq;
CREATE SEQUENCE IF NOT EXISTS tasklistitem_seq;
CREATE SEQUENCE IF NOT EXISTS registrationdata_seq;
CREATE SEQUENCE IF NOT EXISTS subscription_seq;
CREATE SEQUENCE IF NOT EXISTS history_seq;
CREATE SEQUENCE IF NOT EXISTS historystate_seq;
CREATE SEQUENCE IF NOT EXISTS itemsbyauthor_seq;
CREATE SEQUENCE IF NOT EXISTS itemsbytitle_seq;
CREATE SEQUENCE IF NOT EXISTS itemsbydate_seq;
CREATE SEQUENCE IF NOT EXISTS itemsbydateaccessioned_seq;


-------------------------------------------------------
-- BitstreamFormatRegistry table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS BitstreamFormatRegistry
(
  bitstream_format_id INTEGER PRIMARY KEY,
  mimetype            VARCHAR(48),
  short_description   VARCHAR(128) UNIQUE,
  description         TEXT,
  support_level       INTEGER,
  -- Identifies internal types
  internal             BOOL
);

-------------------------------------------------------
-- FileExtension table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS FileExtension
(
  file_extension_id    INTEGER PRIMARY KEY,
  bitstream_format_id  INTEGER REFERENCES BitstreamFormatRegistry(bitstream_format_id),
  extension            VARCHAR(16)
);

-------------------------------------------------------
-- Bitstream table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS Bitstream
(
   bitstream_id            INTEGER PRIMARY KEY,
   bitstream_format_id     INTEGER REFERENCES BitstreamFormatRegistry(bitstream_format_id),
   name                    VARCHAR(256),
   size                    INTEGER,
   checksum                VARCHAR(64),
   checksum_algorithm      VARCHAR(32),
   description             TEXT,
   user_format_description TEXT,
   source                  VARCHAR(256),
   internal_id             VARCHAR(256),
   deleted                 BOOL,
   store_number            INTEGER
);

-------------------------------------------------------
-- EPerson table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS EPerson
(
  eperson_id          INTEGER PRIMARY KEY,
  email               VARCHAR(64) UNIQUE,
  password            VARCHAR(64),
  firstname           VARCHAR(64),
  lastname            VARCHAR(64),
  can_log_in          BOOL,
  require_certificate BOOL,
  self_registered     BOOL,
  last_active         TIMESTAMP,
  sub_frequency       INTEGER,
  phone	              VARCHAR(32)
);

-- index by email
CREATE INDEX IF NOT EXISTS eperson_email_idx ON EPerson(email);

-------------------------------------------------------
-- EPersonGroup table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS EPersonGroup
(
  eperson_group_id INTEGER PRIMARY KEY,
  name             VARCHAR(256) UNIQUE
);

-------------------------------------------------------
-- Item table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS Item
(
  item_id         INTEGER PRIMARY KEY,
  submitter_id    INTEGER REFERENCES EPerson(eperson_id),
  in_archive      BOOL,
  withdrawn       BOOL,
  last_modified   TIMESTAMP
);

-------------------------------------------------------
-- Bundle table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS Bundle
(
  bundle_id          INTEGER PRIMARY KEY,
  mets_bitstream_id  INTEGER REFERENCES Bitstream(bitstream_id)
);

-------------------------------------------------------
-- Item2Bundle table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS Item2Bundle
(
  id        INTEGER PRIMARY KEY,
  item_id   INTEGER REFERENCES Item(item_id),
  bundle_id INTEGER REFERENCES Bundle(bundle_id)
);

-- index by item_id
CREATE INDEX IF NOT EXISTS item2bundle_item_idx on Item2Bundle(item_id);

-------------------------------------------------------
-- Bundle2Bitstream table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS Bundle2Bitstream
(
  id           INTEGER PRIMARY KEY,
  bundle_id    INTEGER REFERENCES Bundle(bundle_id),
  bitstream_id INTEGER REFERENCES Bitstream(bitstream_id)
);

-- index by bundle_id
CREATE INDEX IF NOT EXISTS bundle2bitstream_bundle_idx ON Bundle2Bitstream(bundle_id);

-------------------------------------------------------
-- DCTypeRegistry table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS DCTypeRegistry
(
  dc_type_id INTEGER PRIMARY KEY,
  element    VARCHAR(64),
  qualifier  VARCHAR(64),
  scope_note TEXT,
  UNIQUE(element, qualifier)
);

-------------------------------------------------------
-- DCValue table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS DCValue
(
  dc_value_id   INTEGER PRIMARY KEY,
  item_id       INTEGER REFERENCES Item(item_id),
  dc_type_id    INTEGER REFERENCES DCTypeRegistry(dc_type_id),
  text_value TEXT,
  text_lang  VARCHAR(24),
  place      INTEGER,
  source_id  INTEGER
);

-- An index for item_id - almost all access is based on
-- instantiating the item object, which grabs all dcvalues
-- related to that item
CREATE INDEX IF NOT EXISTS dcvalue_item_idx on DCValue(item_id);

-------------------------------------------------------
-- Community table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS Community
(
  community_id      INTEGER PRIMARY KEY,
  name              VARCHAR(128) UNIQUE,
  short_description VARCHAR(512),
  introductory_text TEXT,
  logo_bitstream_id INTEGER REFERENCES Bitstream(bitstream_id),
  copyright_text    TEXT,
  side_bar_text     TEXT
);

-------------------------------------------------------
-- Collection table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS Collection
(
  collection_id     INTEGER PRIMARY KEY,
  name              VARCHAR(128),
  short_description VARCHAR(512),
  introductory_text TEXT,
  logo_bitstream_id INTEGER REFERENCES Bitstream(bitstream_id),
  template_item_id  INTEGER REFERENCES Item(item_id),
  provenance_description  TEXT,
  license           TEXT,
  copyright_text    TEXT,
  side_bar_text     TEXT,
  workflow_step_1   INTEGER REFERENCES EPersonGroup( eperson_group_id ),
  workflow_step_2   INTEGER REFERENCES EPersonGroup( eperson_group_id ),
  workflow_step_3   INTEGER REFERENCES EPersonGroup( eperson_group_id )
);

-------------------------------------------------------
-- Community2Collection table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS Community2Collection
(
  id             INTEGER PRIMARY KEY,
  community_id   INTEGER REFERENCES Community(community_id),
  collection_id  INTEGER REFERENCES Collection(collection_id)
);

-------------------------------------------------------
-- Collection2Item table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS Collection2Item
(
  id            INTEGER PRIMARY KEY,
  collection_id INTEGER REFERENCES Collection(collection_id),
  item_id       INTEGER REFERENCES Item(item_id)
);

-- index by collection_id
CREATE INDEX IF NOT EXISTS collection2item_collection_idx ON Collection2Item(collection_id);

-------------------------------------------------------
-- ResourcePolicy table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS ResourcePolicy
(
  policy_id            INTEGER PRIMARY KEY,
  resource_type_id     INTEGER,
  resource_id          INTEGER,
  action_id            INTEGER,
  eperson_id           INTEGER REFERENCES EPerson(eperson_id),
  epersongroup_id      INTEGER REFERENCES EPersonGroup(eperson_group_id),
  start_date           DATE,
  end_date             DATE
);

-- index by resource_type,resource_id - all queries by
-- authorization manager are select type=x, id=y, action=z
CREATE INDEX IF NOT EXISTS resourcepolicy_type_id_idx ON ResourcePolicy(resource_type_id,resource_id); 

-------------------------------------------------------
-- EPersonGroup2EPerson table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS EPersonGroup2EPerson
(
  id               INTEGER PRIMARY KEY,
  eperson_group_id INTEGER REFERENCES EPersonGroup(eperson_group_id),
  eperson_id       INTEGER REFERENCES EPerson(eperson_id)
);

-- Index by group ID (used heavily by AuthorizeManager)
CREATE INDEX IF NOT EXISTS epersongroup2eperson_group_idx on EPersonGroup2EPerson(eperson_group_id);


-------------------------------------------------------
-- Handle table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS Handle
(
  handle_id        INTEGER PRIMARY KEY,
  handle           VARCHAR(256) UNIQUE,
  resource_type_id INTEGER,
  resource_id      INTEGER
);

-- index by handle, commonly looked up
CREATE INDEX IF NOT EXISTS handle_handle_idx ON Handle(handle);

-------------------------------------------------------
--  WorkspaceItem table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS WorkspaceItem
(
  workspace_item_id INTEGER PRIMARY KEY,
  item_id           INTEGER REFERENCES Item(item_id),
  collection_id     INTEGER REFERENCES Collection(collection_id),
  -- Answers to questions on first page of submit UI
  multiple_titles   BOOL,
  published_before  BOOL,
  multiple_files    BOOL,
  -- How for the user has got in the submit process
  stage_reached     INTEGER
);

-------------------------------------------------------
--  WorkflowItem table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS WorkflowItem
(
  workflow_id    INTEGER PRIMARY KEY,
  item_id        INTEGER REFERENCES Item(item_id) UNIQUE,
  collection_id  INTEGER REFERENCES Collection(collection_id),
  state          INTEGER,
  owner          INTEGER REFERENCES EPerson(eperson_id),

  -- Answers to questions on first page of submit UI
  multiple_titles       BOOL,
  published_before      BOOL,
  multiple_files        BOOL
  -- Note: stage reached not applicable here - people involved in workflow
  -- can always jump around submission UI

);

-------------------------------------------------------
--  TasklistItem table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS TasklistItem
(
  tasklist_id	INTEGER PRIMARY KEY,
  eperson_id	INTEGER REFERENCES EPerson(eperson_id),
  workflow_id	INTEGER REFERENCES WorkflowItem(workflow_id)
);


-------------------------------------------------------
--  RegistrationData table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS RegistrationData
(
  registrationdata_id   INTEGER PRIMARY KEY,
  email                 VARCHAR(64) UNIQUE,
  token                 VARCHAR(48),
  expires		TIMESTAMP
);


-------------------------------------------------------
--  Subscription table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS Subscription
(
  subscription_id   INTEGER PRIMARY KEY,
  eperson_id        INTEGER REFERENCES EPerson(eperson_id),
  collection_id     INTEGER REFERENCES Collection(collection_id)
);


-------------------------------------------------------
--  History table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS History
(
  history_id           INTEGER PRIMARY KEY,
  -- When it was stored
  creation_date        TIMESTAMP,
  -- A checksum to keep INTEGERizations from being stored more than once
  checksum             VARCHAR(32) UNIQUE
);

-------------------------------------------------------
--  HistoryState table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS HistoryState
(
  history_state_id           INTEGER PRIMARY KEY,
  object_id                  VARCHAR(64)
);

------------------------------------------------------------
-- Browse subsystem tables and views
------------------------------------------------------------

-------------------------------------------------------
--  Community2Item view
-------------------------------------------------------
CREATE VIEW IF NOT EXISTS Community2Item as
SELECT Community2Collection.community_id, Collection2Item.item_id 
FROM Community2Collection, Collection2Item
WHERE Collection2Item.collection_id   = Community2Collection.collection_id
;

-------------------------------------------------------
--  ItemsByAuthor table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS ItemsByAuthor
(
   items_by_author_id INTEGER PRIMARY KEY,
   item_id            INTEGER REFERENCES Item(item_id),
   author             TEXT,
   sort_author        TEXT
);

-- index by sort_author, of course!
CREATE INDEX IF NOT EXISTS sort_author_idx on ItemsByAuthor(sort_author);

-------------------------------------------------------
--  CollectionItemsByAuthor view
-------------------------------------------------------
CREATE VIEW IF NOT EXISTS CollectionItemsByAuthor as
SELECT Collection2Item.collection_id, ItemsByAuthor.* 
FROM ItemsByAuthor, Collection2Item
WHERE ItemsByAuthor.item_id = Collection2Item.item_id
;

-------------------------------------------------------
--  CommunityItemsByAuthor view
-------------------------------------------------------
CREATE VIEW IF NOT EXISTS CommunityItemsByAuthor as
SELECT Community2Item.community_id, ItemsByAuthor.* 
FROM ItemsByAuthor, Community2Item
WHERE ItemsByAuthor.item_id = Community2Item.item_id
;

----------------------------------------
-- ItemsByTitle table
----------------------------------------
CREATE TABLE IF NOT EXISTS ItemsByTitle
(
   items_by_title_id  INTEGER PRIMARY KEY,
   item_id            INTEGER REFERENCES Item(item_id),
   title              TEXT,
   sort_title         TEXT
);

-- index by the sort_title
CREATE INDEX IF NOT EXISTS sort_title_idx on ItemsByTitle(sort_title);


-------------------------------------------------------
--  CollectionItemsByTitle view
-------------------------------------------------------
CREATE VIEW IF NOT EXISTS CollectionItemsByTitle as
SELECT Collection2Item.collection_id, ItemsByTitle.* 
FROM ItemsByTitle, Collection2Item
WHERE ItemsByTitle.item_id = Collection2Item.item_id
;

-------------------------------------------------------
--  CommunityItemsByTitle view
-------------------------------------------------------
CREATE VIEW IF NOT EXISTS CommunityItemsByTitle as
SELECT Community2Item.community_id, ItemsByTitle.* 
FROM ItemsByTitle, Community2Item
WHERE ItemsByTitle.item_id = Community2Item.item_id
;

-------------------------------------------------------
--  ItemsByDate table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS ItemsByDate
(
   items_by_date_id   INTEGER PRIMARY KEY,
   item_id            INTEGER REFERENCES Item(item_id),
   date_issued        TEXT
);

-- sort by date
CREATE INDEX IF NOT EXISTS date_issued_idx on ItemsByDate(date_issued);

-------------------------------------------------------
--  CollectionItemsByDate view
-------------------------------------------------------
CREATE VIEW IF NOT EXISTS CollectionItemsByDate as
SELECT Collection2Item.collection_id, ItemsByDate.* 
FROM ItemsByDate, Collection2Item
WHERE ItemsByDate.item_id = Collection2Item.item_id
;

-------------------------------------------------------
--  CommunityItemsByDate view
-------------------------------------------------------
CREATE VIEW IF NOT EXISTS CommunityItemsByDate as
SELECT Community2Item.community_id, ItemsByDate.* 
FROM ItemsByDate, Community2Item
WHERE ItemsByDate.item_id = Community2Item.item_id
;

-------------------------------------------------------
--  ItemsByDateAccessioned table
-------------------------------------------------------
CREATE TABLE IF NOT EXISTS ItemsByDateAccessioned
(
   items_by_date_accessioned_id  INTEGER PRIMARY KEY,
   item_id                       INTEGER REFERENCES Item(item_id),
   date_accessioned              TEXT
);

-------------------------------------------------------
--  CollectionItemsByDateAccession view
-------------------------------------------------------
CREATE VIEW IF NOT EXISTS CollectionItemsByDateAccession as
SELECT Collection2Item.collection_id, ItemsByDateAccessioned.* 
FROM ItemsByDateAccessioned, Collection2Item
WHERE ItemsByDateAccessioned.item_id = Collection2Item.item_id
;

-------------------------------------------------------
--  CommunityItemsByDateAccession view
-------------------------------------------------------
CREATE VIEW IF NOT EXISTS CommunityItemsByDateAccession as
SELECT Community2Item.community_id, ItemsByDateAccessioned.* 
FROM ItemsByDateAccessioned, Community2Item
WHERE ItemsByDateAccessioned.item_id = Community2Item.item_id
;
