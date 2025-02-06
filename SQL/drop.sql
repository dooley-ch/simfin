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

do
$drop_owned_objects$
begin
    if exists(select * from pg_roles where rolname='simfin_dev_group') then
        drop owned by simfin_dev_group;
    end if;

    if exists(select * from pg_roles where rolname='simfin_admin_group') then
        drop owned by simfin_admin_group;
    end if;

    if exists(select * from pg_roles where rolname='simfin_users_group') then
        drop owned by simfin_users_group;
    end if;
end
$drop_owned_objects$;

drop user if exists simfin_dev_user;
drop user if exists simfin_admin_user;
drop user if exists simfin_user;

drop group if exists simfin_dev_group;
drop group if exists simfin_admin_group;
drop group if exists simfin_users_group;

drop user if exists simfin_owner;
