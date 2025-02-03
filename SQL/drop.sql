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

drop table if exists public.income_statement_general cascade;
drop table if exists public.income_statement_bank cascade;
drop table if exists public.income_statement_insurance cascade;
drop table if exists public.cash_flow_general cascade;
drop table if exists public.cash_flow_bank cascade;
drop table if exists public.cash_flow_insurance cascade;
drop table if exists public.balance_sheet_general cascade;
drop table if exists public.balance_sheet_bank cascade;
drop table if exists public.balance_sheet_insurance cascade;
drop table if exists public.stock_price cascade;
drop table if exists public.company cascade;
drop table if exists public.company_type cascade;
drop table if exists public.stock_market cascade;
drop table if exists public.currency cascade;
drop table if exists public.industry cascade;
drop table if exists public.sector cascade;
drop table if exists public.accounting_period cascade;
drop table if exists public.country cascade;