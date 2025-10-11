-- sql/01_schemas.sql
create schema if not exists ext;    -- external (Spectrum)
create schema if not exists stage;  -- landing inside Redshift
create schema if not exists core;   -- normalized/core
create schema if not exists marts;  -- star-schema marts for BI
