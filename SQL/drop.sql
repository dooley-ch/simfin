-- *******************************************************************************************
--   File:  drop.sql
--
--  © 2025 James Dooley (james@dooley.ch)
--
--  Created: 02.02.2025
--
--  History:
--      02.02.2025: Initial version
--
-- *******************************************************************************************

drop schema if exists staging cascade;

drop table if exists public.sys_version;
