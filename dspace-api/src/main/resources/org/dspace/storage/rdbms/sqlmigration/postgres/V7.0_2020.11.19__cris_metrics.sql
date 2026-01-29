--
-- The contents of this file are subject to the license and copyright
-- detailed in the LICENSE and NOTICE files at the root of the source
-- tree and available online at
--
-- http://www.dspace.org/license/
--

-----------------------------------------------------------------------------------
-- Create table IF NOT EXISTS for CrisMetrics
-----------------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS cris_metrics_seq;

CREATE TABLE IF NOT EXISTS cris_metrics
(
    id INTEGER NOT NULL,
    metricType CHARACTER VARYING(255),
    metricCount FLOAT,
    acquisitionDate TIMESTAMP,
    startDate TIMESTAMP,
    endDate TIMESTAMP,
    resource_id UUID NOT NULL,
    last BOOLEAN,
    remark TEXT,
    CONSTRAINT cris_metrics_pkey PRIMARY KEY (id),
    CONSTRAINT cris_metrics_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES item (uuid)
);

CREATE INDEX IF NOT EXISTS metrics_last_idx
ON public.cris_metrics
USING btree
(last);

CREATE INDEX IF NOT EXISTS metrics_uuid_idx
ON public.cris_metrics
USING btree
(resource_id);
  
CREATE INDEX IF NOT EXISTS metric_bid_idx
ON public.cris_metrics
USING btree
(resource_id, metricType COLLATE pg_catalog."default");