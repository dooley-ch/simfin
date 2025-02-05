-- *******************************************************************************************
--   File:  install.sql
--
--  © 2025 James Dooley (james@dooley.ch)
--
--  Created: 02.02.2025
--
--  History:
--      02.02.2025: Initial version
--
-- *******************************************************************************************

create schema if not exists public;
create schema if not exists staging;

-- region Version Number

create table public.sys_version(
                            id smallserial not null,
                            major smallint not null,
                            minor smallint not null,
                            build smallint not null,
                            extra_data varchar(2048),
                            is_valid bool not null default false,
                            record_version smallint not null default 1,
                            created_on timestamp with time zone not null default current_timestamp,
                            updated_on timestamp with time zone not null default current_timestamp,
                            constraint sys_version_pkey primary key(id)
);

create unique index sys_version_major_minor_build_idx on sys_version (major, minor, build);

insert into public.sys_version(major, minor, build) values (1,0, 1);

-- endregion Version Number

-- region Application Tables

-- region Master Tables

create table accounting_period(
                                  id smallserial not null,
                                  "name" name not null,
                                  active bool not null default true,
                                  record_version smallint not null default 1,
                                  created_on timestamp with time zone not null default current_timestamp,
                                  updated_on timestamp with time zone not null default current_timestamp,
                                  constraint accounting_period_pkey primary key(id)
);

CREATE UNIQUE INDEX accounting_period_idx ON accounting_period(name);

create table company(
                        id bigserial not null,
                        company_number char(8) not null,
                        ticker varchar(20) not null,
                        company_name varchar(120) not null,
                        isin char(12),
                        cik char(20),
                        end_of_year_month char(2),
                        employees bigserial,
                        business text,
                        active bool not null default true,
                        company_type_id smallint not null,
                        industry_id smallint not null,
                        currency_id smallint not null,
                        stock_market_id smallint not null,
                        country_id smallint not null,
                        record_version smallint not null default 1,
                        created_on timestamp with time zone not null default current_timestamp,
                        updated_on timestamp with time zone not null default current_timestamp,
                        constraint company_pkey primary key(id),
                        constraint company_company_number_ukey UNIQUE(company_number),
                        constraint company_ticker_ukey UNIQUE(ticker)
);

create table company_type(
                             id smallserial not null,
                             type_name name not null,
                             active bool not null default true,
                             record_version smallint not null default 1,
                             created_on timestamp with time zone not null default current_timestamp,
                             updated_on timestamp with time zone not null default current_timestamp,
                             constraint company_type_pkey primary key(id)
);

CREATE UNIQUE INDEX company_type_name_idx ON company_type(type_name);

create table country(
                        id smallserial not null,
                        country_name name not null,
                        country_key char(3) not null,
                        active bool not null default true,
                        record_version smallint not null default 1,
                        created_on timestamp with time zone not null default current_timestamp,
                        updated_on timestamp with time zone not null default current_timestamp,
                        constraint country_pkey primary key(id)
);

CREATE UNIQUE INDEX country_key_idx ON country(country_key);

create table currency(
                         id smallserial not null,
                         currency_name name not null,
                         currency_key char(3) not null,
                         active bool not null default true,
                         record_version smallint not null default 1,
                         created_on timestamp with time zone not null default current_timestamp,
                         updated_on timestamp with time zone not null default current_timestamp,
                         constraint currency_pkey primary key(id)
);

CREATE UNIQUE INDEX currency_key_idx ON currency(currency_key);

create table industry(
                         id smallserial not null,
                         industry_name name not null,
                         active bool not null default true,
                         sector_id smallint not null,
                         record_version smallint not null default 1,
                         created_on timestamp with time zone not null default current_timestamp,
                         updated_on timestamp with time zone not null default current_timestamp,
                         constraint industry_pkey primary key(id)
);

CREATE UNIQUE INDEX industry_sector_id_name_idx ON industry(sector_id, industry_name);

create table sector(
                       id smallserial not null,
                       sector_name name not null,
                       active bool not null default true,
                       record_version smallint not null default 1,
                       created_on timestamp with time zone not null default current_timestamp,
                       updated_on timestamp with time zone not null default current_timestamp,
                       constraint sector_pkey primary key(id)
);

CREATE UNIQUE INDEX sector_name_idx ON sector(sector_name);

create table stock_market(
                             id smallserial not null,
                             market_name name not null,
                             extra_data VARCHAR(2048),
                             active bool not null default true,
                             currency_id smallint not null,
                             record_version smallint not null default 1,
                             created_on timestamp with time zone not null default current_timestamp,
                             updated_on timestamp with time zone not null default current_timestamp,
                             constraint stock_market_pkey primary key(id)
);

CREATE UNIQUE INDEX stock_market_name_idx ON stock_market(market_name);

-- endregion

-- region Financial Tables

-- region Income Statements

create table income_statement_general(
                                         id bigserial not null,
                                         fiscal_year integer not null,
                                         fiscal_period char(2) not null,
                                         report_date date not null,
                                         publish_date date not null,
                                         restated_date date,
                                         shares_basic bigint,
                                         shares_diluted bigint,
                                         revenue numeric(32,2),
                                         cost_of_revenue numeric(32,2),
                                         gross_profit numeric(32,2),
                                         operating_expenses numeric(32,2),
                                         selling_general_administrative numeric(32,2),
                                         research_development numeric(32,2),
                                         depreciation_amortization numeric(32,2),
                                         operating_income numeric(32,2),
                                         non_operating_income numeric(32,2),
                                         interest_expense_net numeric(32,2),
                                         pretax_income_loss_adj numeric(32,2),
                                         abnormal_gains numeric(32,2),
                                         pretax_income numeric(32,2),
                                         income_tax_benefit_net numeric(32,2),
                                         income_from_continuing_operations numeric(32,2),
                                         net_extraordinary_gains numeric(32,2),
                                         net_income numeric(32,2),
                                         net_income_common numeric(32,2),
                                         company_id bigint not null,
                                         currency_id smallint not null,
                                         accounting_period_id smallint not null,
                                         created_on timestamp with time zone not null default current_timestamp,
                                         constraint income_statement_general_pkey primary key(id)
);

create table income_statement_bank(
                                      id bigserial not null,
                                      fiscal_year integer not null,
                                      fiscal_period char(2) not null,
                                      report_date date not null,
                                      publish_date date not null,
                                      restated_date date,
                                      shares_basic bigint,
                                      shares_diluted bigint,
                                      revenue numeric(32,2),
                                      provision_for_loan_losses numeric(32,2),
                                      net_revenue_after_provisions numeric(32,2),
                                      total_non_interest_expense numeric(32,2),
                                      operating_income numeric(32,2),
                                      non_operating_income numeric(32,2),
                                      pretax_income numeric(32,2),
                                      income_tax_benefit_net numeric(32,2),
                                      income_from_continuing_operations numeric(32,2),
                                      net_extraordinary_gains numeric(32,2),
                                      net_income numeric(32,2),
                                      net_income_common numeric(32,2),
                                      company_id bigint not null,
                                      currency_id smallint not null,
                                      accounting_period_id smallint not null,
                                      created_on timestamp with time zone not null default current_timestamp,
                                      constraint income_statement_bank_pkey primary key(id)
);

create table income_statement_insurance(
                                           id bigserial not null,
                                           fiscal_year integer not null,
                                           fiscal_period char(2) not null,
                                           report_date date not null,
                                           publish_date date not null,
                                           restated_date date,
                                           shares_basic bigint,
                                           shares_diluted bigint,
                                           revenue numeric(32,2),
                                           total_claims_losses numeric(32,2),
                                           operating_income numeric(32,2),
                                           pretax_income numeric(32,2),
                                           income_tax_benefit_net numeric(32,2),
                                           income_from_affiliates_net_of_taxes numeric(32,2),
                                           income_from_continuing_operations numeric(32,2),
                                           net_extraordinary_gains numeric(32,2),
                                           net_income numeric(32,2),
                                           net_income_common numeric(32,2),
                                           company_id bigint not null,
                                           currency_id smallint not null,
                                           accounting_period_id smallint not null,
                                           created_on timestamp with time zone not null default current_timestamp,
                                           constraint income_statement_insurance_pkey primary key(id)
);

-- endregion

-- region Cash Flow Statements

create table cash_flow_general(
                                  id bigserial not null,
                                  fiscal_year integer not null,
                                  fiscal_period char(2) not null,
                                  report_date date not null,
                                  publish_date date not null,
                                  restated_date date,
                                  shares_basic bigint,
                                  shares_diluted bigint,
                                  net_income numeric(32,2),
                                  depreciation_amortization numeric(32,2),
                                  non_cash_item numeric(32,2),
                                  change_in_working_capital numeric(32,2),
                                  change_in_accounts_receivable numeric(32,2),
                                  change_in_inventories numeric(32,2),
                                  change_in_accounts_payable numeric(32,2),
                                  change_in_other numeric(32,2),
                                  met_cash_from_operating_activities numeric(32,2),
                                  change_in_fixed_assets_intangibles numeric(32,2),
                                  net_change_in_long_term_investment numeric(32,2),
                                  net_cash_from_acquisitions_divestitures numeric(32,2),
                                  net_cash_from_investing_activities numeric(32,2),
                                  dividends_paid numeric(32,2),
                                  cash_from_repayment_of_debt numeric(32,2),
                                  cash_from_repurchase_of_equity numeric(32,2),
                                  net_cash_from_financing_activities numeric(32,2),
                                  net_change_in_cash numeric(32,2),
                                  company_id bigint not null,
                                  currency_id smallint not null,
                                  accounting_period_id smallint not null,
                                  created_on timestamp with time zone not null default current_timestamp,
                                  constraint cash_flow_general_pkey primary key(id)
);

create table cash_flow_bank(
                               id bigserial not null,
                               fiscal_year integer not null,
                               fiscal_period char(2) not null,
                               report_date date not null,
                               publish_date date not null,
                               restated_date date,
                               shares_basic bigint,
                               shares_diluted bigint,
                               net_income numeric(32,2),
                               depreciation_amortization numeric(32,2),
                               provision_for_loan_losses numeric(32,2),
                               non_cash_items numeric(32,2),
                               change_in_working_capital numeric(32,2),
                               net_cash_from_operating_activities numeric(32,2),
                               change_in_fixed_assets_intangibles numeric(32,2),
                               net_change_in_loans_interbank numeric(32,2),
                               net_cash_from_acquisitions_divestiture numeric(32,2),
                               net_cash_from_investing_activities numeric(32,2),
                               dividends_paid numeric(32,2),
                               cash_from_repayment_of_debt numeric(32,2),
                               cash_from_repurchase_of_equity numeric(32,2),
                               net_cash_from_financing_activities numeric(32,2),
                               effect_of_foreign_exchange_rates numeric(32,2),
                               net_change_in_cash numeric(32,2),
                               company_id bigint not null,
                               currency_id smallint not null,
                               accounting_period_id smallint not null,
                               created_on timestamp with time zone not null default current_timestamp,
                               constraint cash_flow_bank_pkey primary key(id)
);

create table cash_flow_insurance(
                                    id bigserial not null,
                                    fiscal_year integer not null,
                                    fiscal_period char(2) not null,
                                    report_date date not null,
                                    publish_date date not null,
                                    restated_date date,
                                    shares_basic bigint,
                                    shares_diluted bigint,
                                    net_income numeric(32,2),
                                    depreciation_amortization numeric(32,2),
                                    non_cash_items numeric(32,2),
                                    net_cash_from_operating_activities numeric(32,2),
                                    change_in_fixed_assets_intangibles numeric(32,2),
                                    net_change_in_investments numeric(32,2),
                                    net_cash_from_investing_activities numeric(32,2),
                                    dividends_paid numeric(32,2),
                                    cash_from_repayment_of_debt numeric(32,2),
                                    cash_from_repurchase_of_equity numeric(32,2),
                                    net_cash_from_financing_activities numeric(32,2),
                                    effect_of_foreign_exchange_rates numeric(32,2),
                                    net_change_in_cash numeric(32,2),
                                    company_id bigint not null,
                                    currency_id smallint not null,
                                    accounting_period_id smallint not null,
                                    created_on timestamp with time zone not null default current_timestamp,
                                    constraint cash_flow_insurance_pkey primary key(id)
);

-- endregion

-- region Balance Sheets

create table balance_sheet_general(
                                      id bigserial not null,
                                      fiscal_year integer not null,
                                      fiscal_period char(2) not null,
                                      report_date date not null,
                                      publish_date date not null,
                                      restated_date date,
                                      shares_basic bigint,
                                      shares_diluted bigint,
                                      cash_cash_equivalents_short_term_investments numeric(32,2),
                                      accounts_notes_receivable numeric(32,2),
                                      inventories numeric(32,2),
                                      total_current_assets numeric(32,2),
                                      property_plant_equipment_net numeric(32,2),
                                      long_term_investments_receivables numeric(32,2),
                                      other_long_term_assets numeric(32,2),
                                      total_noncurrent_assets numeric(32,2),
                                      total_assets numeric(32,2),
                                      payables_accruals numeric(32,2),
                                      short_term_debt numeric(32,2),
                                      total_current_liabilities numeric(32,2),
                                      long_term_debt numeric(32,2),
                                      total_noncurrent_liabilities numeric(32,2),
                                      total_liabilities numeric(32,2),
                                      share_capital_additional_paid_in_capital numeric(32,2),
                                      treasury_stock numeric(32,2),
                                      retained_earnings numeric(32,2),
                                      total_equity numeric(32,2),
                                      total_liabilities_equity numeric(32,2),
                                      company_id bigint not null,
                                      currency_id smallint not null,
                                      accounting_period_id smallint not null,
                                      created_on timestamp with time zone not null default current_timestamp,
                                      constraint balance_sheet_general_pkey primary key(id)
);

create table balance_sheet_bank(
                                   id bigserial not null,
                                   fiscal_year integer not null,
                                   fiscal_period char(2) not null,
                                   report_date date not null,
                                   publish_date date not null,
                                   restated_date date,
                                   shares_basic bigint,
                                   shares_diluted bigint,
                                   cash_cash_equivalents_short_term_investments numeric(32,2),
                                   interbank_assets numeric(32,2),
                                   short_long_term_investments numeric(32,2),
                                   accounts_notes_receivable numeric(32,2),
                                   net_loans numeric(32,2),
                                   net_fixed_assets numeric(32,2),
                                   total_assets numeric(32,2),
                                   total_deposits numeric(32,2),
                                   short_term_debt numeric(32,2),
                                   long_term_debt numeric(32,2),
                                   total_liabilities numeric(32,2),
                                   preferred_equity numeric(32,2),
                                   share_capital_additional_paid_in_capital numeric(32,2),
                                   treasury_stock numeric(32,2),
                                   retained_earnings numeric(32,2),
                                   total_equity numeric(32,2),
                                   total_liabilities_equity numeric(32,2),
                                   company_id bigint not null,
                                   currency_id smallint not null,
                                   accounting_period_id smallint not null,
                                   created_on timestamp with time zone not null default current_timestamp,
                                   constraint balance_sheet_bank_pkey primary key(id)
);

create table balance_sheet_insurance(
                                        id bigserial not null,
                                        fiscal_year integer not null,
                                        fiscal_period char(2) not null,
                                        report_date date not null,
                                        publish_date date not null,
                                        restated_date date,
                                        shares_basic bigint,
                                        shares_diluted bigint,
                                        total_investments numeric(32,2),
                                        cash_cash_equivalents_short_term_investments numeric(32,2),
                                        accounts_notes_receivable numeric(32,2),
                                        property_plant_equipment_net numeric(32,2),
                                        total_assets numeric(32,2),
                                        insurance_reserves numeric(32,2),
                                        short_term_debt numeric(32,2),
                                        long_term_debt numeric(32,2),
                                        total_liabilities numeric(32,2),
                                        preferred_equity numeric(32,2),
                                        policyholders_equity numeric(32,2),
                                        share_capital_additional_paid_in_capital numeric(32,2),
                                        treasury_stock numeric(32,2),
                                        retained_Earnings numeric(32,2),
                                        total_Equity numeric(32,2),
                                        total_liabilities_equity numeric(32,2),
                                        company_id bigint not null,
                                        currency_id smallint not null,
                                        accounting_period_id smallint not null,
                                        created_on timestamp with time zone not null default current_timestamp,
                                        constraint balance_sheet_insurance_pkey primary key(id)
);

-- endregion

-- region Share Prices

create table stock_price(
                            id bigserial not null,
                            price_date date not null,
                            open numeric(6,2),
                            high numeric(6,2),
                            low numeric(6,2),
                            actual_close numeric(6,2),
                            adj_close numeric(6,2),
                            volume bigserial,
                            dividend numeric(6,2),
                            shares_outstanding bigserial,
                            company_id bigint not null,
                            created_on timestamp with time zone not null default current_timestamp,
                            constraint stock_price_pkey primary key(id)
);

-- endregion

-- endregion

-- region Relationships

alter table industry
    add constraint industry_sector_id_fkey
        foreign key (sector_id) references sector (id);

alter table stock_market
    add constraint stock_market_currency_id_fkey
        foreign key (currency_id) references currency (id);

alter table company
    add constraint company_country_id_fkey
        foreign key (country_id) references country (id);

alter table company
    add constraint company_company_type_id_fkey
        foreign key (company_type_id) references company_type (id);

alter table company
    add constraint company_industry_id_fkey
        foreign key (industry_id) references industry (id);

alter table company
    add constraint company_currency_id_fkey
        foreign key (currency_id) references currency (id);

alter table company
    add constraint company_stock_market_id_fkey
        foreign key (stock_market_id) references stock_market (id);

alter table stock_price
    add constraint stock_price_company_id_fkey
        foreign key (company_id) references company (id);

alter table balance_sheet_bank
    add constraint balance_sheet_bank_company_id_fkey
        foreign key (company_id) references company (id);

alter table balance_sheet_insurance
    add constraint balance_sheet_insurance_company_id_fkey
        foreign key (company_id) references company (id);

alter table balance_sheet_general
    add constraint balance_sheet_general_currency_id_fkey
        foreign key (currency_id) references currency (id);

alter table balance_sheet_bank
    add constraint balance_sheet_bank_currency_id_fkey
        foreign key (currency_id) references currency (id);

alter table balance_sheet_insurance
    add constraint balance_sheet_insurance_currency_id_fkey
        foreign key (currency_id) references currency (id);

alter table balance_sheet_general
    add constraint balance_sheet_general_company_id_fkey
        foreign key (company_id) references company (id);

alter table income_statement_bank
    add constraint income_statement_bank_currency_id_fkey
        foreign key (currency_id) references currency (id);

alter table income_statement_insurance
    add constraint income_statement_insurance_currency_id_fkey
        foreign key (currency_id) references currency (id);

alter table income_statement_general
    add constraint income_statement_general_company_id_fkey
        foreign key (company_id) references company (id);

alter table balance_sheet_insurance
    add constraint balance_sheet_insurance_accounting_period_id_fkey
        foreign key (accounting_period_id) references accounting_period (id);

alter table balance_sheet_bank
    add constraint balance_sheet_bank_accounting_period_id_fkey
        foreign key (accounting_period_id) references accounting_period (id);

alter table balance_sheet_general
    add constraint balance_sheet_general_accounting_period_id_fkey
        foreign key (accounting_period_id) references accounting_period (id);

alter table cash_flow_insurance
    add constraint cash_flow_insurance_accounting_period_id_fkey
        foreign key (accounting_period_id) references accounting_period (id);

alter table cash_flow_bank
    add constraint cash_flow_bank_accounting_period_id_fkey
        foreign key (accounting_period_id) references accounting_period (id);

alter table cash_flow_general
    add constraint cash_flow_general_accounting_period_id_fkey
        foreign key (accounting_period_id) references accounting_period (id);

alter table income_statement_insurance
    add constraint income_statement_insurance_accounting_period_id_fkey
        foreign key (accounting_period_id) references accounting_period (id);

alter table income_statement_bank
    add constraint income_statement_bank_accounting_period_id_fkey
        foreign key (accounting_period_id) references accounting_period (id);

alter table income_statement_general
    add constraint income_statement_general_accounting_period_id_fkey
        foreign key (accounting_period_id) references accounting_period (id);

-- endregion

-- endregion Application Tables

-- region Staging Schema - Tables

-- region Logging Tables

create table staging.log(
    id bigserial not null,
    message text not null,
    message_type_id smallint not null,
    created_on timestamp with time zone not null default current_timestamp,
    constraint log_pkey primary key (id)
);

create table staging.log_message_type(
     id smallserial not null,
     message_name name not null,
     extra_data varchar(1024),
     active bool  not null default true,
     record_version smallint  not null default 1,
     created_on timestamp with time zone  not null default current_timestamp,
     updated_on timestamp with time zone  not null default current_timestamp,
     constraint sys_message_type_pkey primary key(id)
);

alter table staging.log
    add constraint log_message_type_id_fkey
        foreign key (message_type_id) references staging.log_message_type (id);

create view staging.v_log as
    select l.id, l.message, t.message_name, l.created_on FROM staging.log l
        inner join staging.log_message_type t on t.id = l.message_type_id
    order by l.created_on desc ;

-- endregion Logging Tables

create table staging.markets
(
    id smallserial not null ,
    market_id char(2),
    market_name name,
    currency char(3),
    created_on timestamp with time zone not null default current_timestamp,
    constraint markets_pkey primary key (id)
);

create table staging.industries
(
    id smallserial not null,
    industry_id char(6),
    industry name,
    sector name,
    created_on timestamp with time zone not null default current_timestamp,
    constraint imp_sector_industry_pkey primary key(id)
);

-- region Company Tables

create table staging.company_us
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    company_name varchar(100),
    industry_id char(6),
    isin varchar(20),
    end_of_financial_year_month char(2),
    number_employees varchar(12),
    business_summary text,
    market char(2),
    cik varchar(12),
    main_currency char(3),
    created_on timestamp with time zone not null default current_timestamp,
    constraint company_us_pkey primary key(id)
);

create table staging.company_de
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    company_name varchar(100),
    industry_id char(6),
    isin varchar(20),
    end_of_financial_year_month char(2),
    number_employees varchar(12),
    business_summary text,
    market char(2),
    cik varchar(12),
    main_currency char(3),
    created_on timestamp with time zone not null default current_timestamp,
    constraint company_de_pkey primary key(id)
);

create table staging.company_cn
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    company_name varchar(100),
    industry_id char(6),
    isin varchar(20),
    end_of_financial_year_month char(2),
    number_employees varchar(12),
    business_summary text,
    market char(2),
    cik varchar(12),
    main_currency char(3),
    created_on timestamp with time zone not null default current_timestamp,
    constraint company_cn_pkey primary key(id)
);

-- endregion - Company Tables

-- region Share Prices Tables

create table staging.share_prices_us
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    price_date varchar(10),
    open_price varchar(30),
    high_price varchar(30),
    low_price varchar(30),
    close_price varchar(30),
    adj_close_price varchar(30),
    volume varchar(30),
    dividend varchar(20),
    shares_outstanding  varchar(30),
    created_on timestamp with time zone not null default current_timestamp,
    constraint share_prices_us_pkey primary key (id)
);

create table staging.share_prices_de
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    price_date varchar(10),
    open_price varchar(30),
    high_price varchar(30),
    low_price varchar(30),
    close_price varchar(30),
    adj_close_price varchar(30),
    volume varchar(30),
    dividend varchar(20),
    shares_outstanding  varchar(30),
    created_on timestamp with time zone not null default current_timestamp,
    constraint share_prices_de_pkey primary key (id)
);

create table staging.share_prices_cn
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    price_date varchar(10),
    open_price varchar(30),
    high_price varchar(30),
    low_price varchar(30),
    close_price varchar(30),
    adj_close_price varchar(30),
    volume varchar(30),
    dividend varchar(20),
    shares_outstanding  varchar(30),
    created_on timestamp with time zone not null default current_timestamp,
    constraint share_prices_cn_pkey primary key (id)
);

-- endregion Share Prices Tables

-- region Income Tables

-- region USA

create table staging.income_statement_us_general_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(100),
    cost_of_revenue varchar(100),
    gross_profit varchar(100),
    operating_expenses varchar(100),
    selling_general_administrative varchar(100),
    research_development varchar(100),
    depreciation_amortization varchar(100),
    operating_income_loss varchar(100),
    non_operating_income_loss varchar(100),
    interest_expense_net varchar(100),
    pretax_income_loss_adj varchar(100),
    abnormal_gains_losses varchar(100),
    Pretax_income_loss varchar(100),
    income_tax_expense_benefit_net varchar(100),
    income_loss_from_continuing_operations varchar(100),
    net_extraordinary_gains_losses varchar(100),
    net_income varchar(100),
    net_income_common varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_us_general_annual_pkey primary key(id)
);

create table staging.income_statement_us_general_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(100),
    cost_of_revenue varchar(100),
    gross_profit varchar(100),
    operating_expenses varchar(100),
    selling_general_administrative varchar(100),
    research_development varchar(100),
    depreciation_amortization varchar(100),
    operating_income_loss varchar(100),
    non_operating_income_loss varchar(100),
    interest_expense_net varchar(100),
    pretax_income_loss_adj varchar(100),
    abnormal_gains_losses varchar(100),
    Pretax_income_loss varchar(100),
    income_tax_expense_benefit_net varchar(100),
    income_loss_from_continuing_operations varchar(100),
    net_extraordinary_gains_losses varchar(100),
    net_income varchar(100),
    net_income_common varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_us_general_quarterly_pkey primary key(id)
);

create table staging.income_statement_us_general_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(100),
    cost_of_revenue varchar(100),
    gross_profit varchar(100),
    operating_expenses varchar(100),
    selling_general_administrative varchar(100),
    research_development varchar(100),
    depreciation_amortization varchar(100),
    operating_income_loss varchar(100),
    non_operating_income_loss varchar(100),
    interest_expense_net varchar(100),
    pretax_income_loss_adj varchar(100),
    abnormal_gains_losses varchar(100),
    Pretax_income_loss varchar(100),
    income_tax_expense_benefit_net varchar(100),
    income_loss_from_continuing_operations varchar(100),
    net_extraordinary_gains_losses varchar(100),
    net_income varchar(100),
    net_income_common varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_us_general_ttm_pkey primary key(id)
);

create table staging.income_statement_us_bank_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    provision_for_loan_losses varchar(40),
    net_revenue_after_provisions varchar(40),
    total_non_interest_expense varchar(40),
    operating_income_loss varchar(40),
    non_operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_us_bank_annual_pkey primary key(id)
);

create table staging.income_statement_us_bank_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    provision_for_loan_losses varchar(40),
    net_revenue_after_provisions varchar(40),
    total_non_interest_expense varchar(40),
    operating_income_loss varchar(40),
    non_operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_us_bank_quarterly_pkey primary key(id)
);

create table staging.income_statement_us_bank_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    provision_for_loan_losses varchar(40),
    net_revenue_after_provisions varchar(40),
    total_non_interest_expense varchar(40),
    operating_income_loss varchar(40),
    non_operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_us_bank_ttm_pkey primary key(id)
);

create table staging.income_statement_us_insurance_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    total_claims_losses varchar(40),
    operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_affiliates_net_of_taxes varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_us_insurance_annual_pkey primary key(id)
);

create table staging.income_statement_us_insurance_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    total_claims_losses varchar(40),
    operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_affiliates_net_of_taxes varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_us_insurance_quarterly_pkey primary key(id)
);

create table staging.income_statement_us_insurance_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    total_claims_losses varchar(40),
    operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_affiliates_net_of_taxes varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_us_insurance_ttm_pkey primary key(id)
);    

-- endregion USA

-- region Germany

create table staging.income_statement_de_general_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(100),
    cost_of_revenue varchar(100),
    gross_profit varchar(100),
    operating_expenses varchar(100),
    selling_general_administrative varchar(100),
    research_development varchar(100),
    depreciation_amortization varchar(100),
    operating_income_loss varchar(100),
    non_operating_income_loss varchar(100),
    interest_expense_net varchar(100),
    pretax_income_loss_adj varchar(100),
    abnormal_gains_losses varchar(100),
    Pretax_income_loss varchar(100),
    income_tax_expense_benefit_net varchar(100),
    income_loss_from_continuing_operations varchar(100),
    net_extraordinary_gains_losses varchar(100),
    net_income varchar(100),
    net_income_common varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_de_general_annual_pkey primary key(id)
);

create table staging.income_statement_de_general_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(100),
    cost_of_revenue varchar(100),
    gross_profit varchar(100),
    operating_expenses varchar(100),
    selling_general_administrative varchar(100),
    research_development varchar(100),
    depreciation_amortization varchar(100),
    operating_income_loss varchar(100),
    non_operating_income_loss varchar(100),
    interest_expense_net varchar(100),
    pretax_income_loss_adj varchar(100),
    abnormal_gains_losses varchar(100),
    Pretax_income_loss varchar(100),
    income_tax_expense_benefit_net varchar(100),
    income_loss_from_continuing_operations varchar(100),
    net_extraordinary_gains_losses varchar(100),
    net_income varchar(100),
    net_income_common varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_de_general_quarterly_pkey primary key(id)
);

create table staging.income_statement_de_general_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(100),
    cost_of_revenue varchar(100),
    gross_profit varchar(100),
    operating_expenses varchar(100),
    selling_general_administrative varchar(100),
    research_development varchar(100),
    depreciation_amortization varchar(100),
    operating_income_loss varchar(100),
    non_operating_income_loss varchar(100),
    interest_expense_net varchar(100),
    pretax_income_loss_adj varchar(100),
    abnormal_gains_losses varchar(100),
    Pretax_income_loss varchar(100),
    income_tax_expense_benefit_net varchar(100),
    income_loss_from_continuing_operations varchar(100),
    net_extraordinary_gains_losses varchar(100),
    net_income varchar(100),
    net_income_common varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_de_general_ttm_pkey primary key(id)
);

create table staging.income_statement_de_bank_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    provision_for_loan_losses varchar(40),
    net_revenue_after_provisions varchar(40),
    total_non_interest_expense varchar(40),
    operating_income_loss varchar(40),
    non_operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_de_bank_annual_pkey primary key(id)
);

create table staging.income_statement_de_bank_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    provision_for_loan_losses varchar(40),
    net_revenue_after_provisions varchar(40),
    total_non_interest_expense varchar(40),
    operating_income_loss varchar(40),
    non_operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_de_bank_quarterly_pkey primary key(id)
);

create table staging.income_statement_de_bank_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    provision_for_loan_losses varchar(40),
    net_revenue_after_provisions varchar(40),
    total_non_interest_expense varchar(40),
    operating_income_loss varchar(40),
    non_operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_de_bank_ttm_pkey primary key(id)
);

create table staging.income_statement_de_insurance_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    total_claims_losses varchar(40),
    operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_affiliates_net_of_taxes varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_de_insurance_annual_pkey primary key(id)
);

create table staging.income_statement_de_insurance_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    total_claims_losses varchar(40),
    operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_affiliates_net_of_taxes varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_de_insurance_quarterly_pkey primary key(id)
);

create table staging.income_statement_de_insurance_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    total_claims_losses varchar(40),
    operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_affiliates_net_of_taxes varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_de_insurance_ttm_pkey primary key(id)
);

-- endregion Germany

-- region China

create table staging.income_statement_cn_general_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(100),
    cost_of_revenue varchar(100),
    gross_profit varchar(100),
    operating_expenses varchar(100),
    selling_general_administrative varchar(100),
    research_development varchar(100),
    depreciation_amortization varchar(100),
    operating_income_loss varchar(100),
    non_operating_income_loss varchar(100),
    interest_expense_net varchar(100),
    pretax_income_loss_adj varchar(100),
    abnormal_gains_losses varchar(100),
    Pretax_income_loss varchar(100),
    income_tax_expense_benefit_net varchar(100),
    income_loss_from_continuing_operations varchar(100),
    net_extraordinary_gains_losses varchar(100),
    net_income varchar(100),
    net_income_common varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_cn_general_annual_pkey primary key(id)
);

create table staging.income_statement_cn_general_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(100),
    cost_of_revenue varchar(100),
    gross_profit varchar(100),
    operating_expenses varchar(100),
    selling_general_administrative varchar(100),
    research_development varchar(100),
    depreciation_amortization varchar(100),
    operating_income_loss varchar(100),
    non_operating_income_loss varchar(100),
    interest_expense_net varchar(100),
    pretax_income_loss_adj varchar(100),
    abnormal_gains_losses varchar(100),
    Pretax_income_loss varchar(100),
    income_tax_expense_benefit_net varchar(100),
    income_loss_from_continuing_operations varchar(100),
    net_extraordinary_gains_losses varchar(100),
    net_income varchar(100),
    net_income_common varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_cn_general_quarterly_pkey primary key(id)
);

create table staging.income_statement_cn_general_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(100),
    cost_of_revenue varchar(100),
    gross_profit varchar(100),
    operating_expenses varchar(100),
    selling_general_administrative varchar(100),
    research_development varchar(100),
    depreciation_amortization varchar(100),
    operating_income_loss varchar(100),
    non_operating_income_loss varchar(100),
    interest_expense_net varchar(100),
    pretax_income_loss_adj varchar(100),
    abnormal_gains_losses varchar(100),
    Pretax_income_loss varchar(100),
    income_tax_expense_benefit_net varchar(100),
    income_loss_from_continuing_operations varchar(100),
    net_extraordinary_gains_losses varchar(100),
    net_income varchar(100),
    net_income_common varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_cn_general_ttm_pkey primary key(id)
);

create table staging.income_statement_cn_bank_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    provision_for_loan_losses varchar(40),
    net_revenue_after_provisions varchar(40),
    total_non_interest_expense varchar(40),
    operating_income_loss varchar(40),
    non_operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_cn_bank_annual_pkey primary key(id)
);

create table staging.income_statement_cn_bank_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    provision_for_loan_losses varchar(40),
    net_revenue_after_provisions varchar(40),
    total_non_interest_expense varchar(40),
    operating_income_loss varchar(40),
    non_operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_cn_bank_quarterly_pkey primary key(id)
);

create table staging.income_statement_cn_bank_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    provision_for_loan_losses varchar(40),
    net_revenue_after_provisions varchar(40),
    total_non_interest_expense varchar(40),
    operating_income_loss varchar(40),
    non_operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_cn_bank_ttm_pkey primary key(id)
);

create table staging.income_statement_cn_insurance_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    total_claims_losses varchar(40),
    operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_affiliates_net_of_taxes varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_cn_insurance_annual_pkey primary key(id)
);

create table staging.income_statement_cn_insurance_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    total_claims_losses varchar(40),
    operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_affiliates_net_of_taxes varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_cn_insurance_quarterly_pkey primary key(id)
);

create table staging.income_statement_cn_insurance_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    revenue varchar(40),
    total_claims_losses varchar(40),
    operating_income_loss varchar(40),
    pretax_income_loss varchar(40),
    income_tax_expense_benefit_net varchar(40),
    income_loss_from_affiliates_net_of_taxes varchar(40),
    income_loss_from_continuing_operations varchar(40),
    net_extraordinary_gains_losses varchar(40),
    net_income varchar(40),
    net_income_common varchar(40),
    created_on timestamp with time zone not null default current_timestamp,
    constraint income_statement_cn_insurance_ttm_pkey primary key(id)
);

-- endregion China
    
-- endregion Income Tables

-- region Cash Flow Tables

-- region USA

create table staging.cash_flow_us_general_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    change_in_accounts_receivable varchar(100),
    change_in_inventories varchar(100),
    change_in_accounts_payable varchar(100),
    change_in_other varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_long_term_investment varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint imp_us_us_cash_flow_general_annual_pkey primary key(id)
);

create table staging.cash_flow_us_general_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    change_in_accounts_receivable varchar(100),
    change_in_inventories varchar(100),
    change_in_accounts_payable varchar(100),
    change_in_other varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_long_term_investment varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint imp_us_us_cash_flow_general_quarterly_pkey primary key(id)
);

create table staging.cash_flow_us_general_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    change_in_accounts_receivable varchar(100),
    change_in_inventories varchar(100),
    change_in_accounts_payable varchar(100),
    change_in_other varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_long_term_investment varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint imp_us_us_cash_flow_general_ttm_pkey primary key(id)
);

create table staging.cash_flow_us_bank_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    provision_for_loan_losses varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_loans_interbank varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rates varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_us_bank_annual_pkey primary key(id)
);

create table staging.cash_flow_us_bank_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    provision_for_loan_losses varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_loans_interbank varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rates varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_us_bank_quarterly_pkey primary key(id)
);

create table staging.cash_flow_us_bank_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    provision_for_loan_losses varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_loans_interbank varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rates varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_us_bank_ttm_pkey primary key(id)
);

create table staging.cash_flow_us_insurance_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_investments varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rate varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_us_insurance_annual_pkey primary key(id)
);

create table staging.cash_flow_us_insurance_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_investments varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rate varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_us_insurance_quarterly_pkey primary key(id)
);

create table staging.cash_flow_us_insurance_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_investments varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rate varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_us_insurance_ttm_pkey primary key(id)
);

-- endregion USA

-- region Germany

create table staging.cash_flow_de_general_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    change_in_accounts_receivable varchar(100),
    change_in_inventories varchar(100),
    change_in_accounts_payable varchar(100),
    change_in_other varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_long_term_investment varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint imp_de_us_cash_flow_general_annual_pkey primary key(id)
);

create table staging.cash_flow_de_general_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    change_in_accounts_receivable varchar(100),
    change_in_inventories varchar(100),
    change_in_accounts_payable varchar(100),
    change_in_other varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_long_term_investment varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint imp_de_us_cash_flow_general_quarterly_pkey primary key(id)
);

create table staging.cash_flow_de_general_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    change_in_accounts_receivable varchar(100),
    change_in_inventories varchar(100),
    change_in_accounts_payable varchar(100),
    change_in_other varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_long_term_investment varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint imp_de_us_cash_flow_general_ttm_pkey primary key(id)
);

create table staging.cash_flow_de_bank_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    provision_for_loan_losses varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_loans_interbank varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rates varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_de_bank_annual_pkey primary key(id)
);

create table staging.cash_flow_de_bank_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    provision_for_loan_losses varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_loans_interbank varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rates varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_de_bank_quarterly_pkey primary key(id)
);

create table staging.cash_flow_de_bank_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    provision_for_loan_losses varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_loans_interbank varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rates varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_de_bank_ttm_pkey primary key(id)
);

create table staging.cash_flow_de_insurance_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_investments varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rate varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_de_insurance_annual_pkey primary key(id)
);

create table staging.cash_flow_de_insurance_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_investments varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rate varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_de_insurance_quarterly_pkey primary key(id)
);

create table staging.cash_flow_de_insurance_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_investments varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rate varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_de_insurance_ttm_pkey primary key(id)
);

-- endregion Germany

-- region China

create table staging.cash_flow_cn_general_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    change_in_accounts_receivable varchar(100),
    change_in_inventories varchar(100),
    change_in_accounts_payable varchar(100),
    change_in_other varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_long_term_investment varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint imp_cn_us_cash_flow_general_annual_pkey primary key(id)
);

create table staging.cash_flow_cn_general_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    change_in_accounts_receivable varchar(100),
    change_in_inventories varchar(100),
    change_in_accounts_payable varchar(100),
    change_in_other varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_long_term_investment varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint imp_cn_us_cash_flow_general_quarterly_pkey primary key(id)
);

create table staging.cash_flow_cn_general_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    change_in_accounts_receivable varchar(100),
    change_in_inventories varchar(100),
    change_in_accounts_payable varchar(100),
    change_in_other varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_long_term_investment varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint imp_cn_us_cash_flow_general_ttm_pkey primary key(id)
);

create table staging.cash_flow_cn_bank_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    provision_for_loan_losses varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_loans_interbank varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rates varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_cn_bank_annual_pkey primary key(id)
);

create table staging.cash_flow_cn_bank_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    provision_for_loan_losses varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_loans_interbank varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rates varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_cn_bank_quarterly_pkey primary key(id)
);

create table staging.cash_flow_cn_bank_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    provision_for_loan_losses varchar(100),
    non_cash_items varchar(100),
    change_in_working_capital varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_loans_interbank varchar(100),
    net_cash_from_acquisitions_divestitures varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rates varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_cn_bank_ttm_pkey primary key(id)
);

create table staging.cash_flow_cn_insurance_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_investments varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rate varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_cn_insurance_annual_pkey primary key(id)
);

create table staging.cash_flow_cn_insurance_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_investments varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rate varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_cn_insurance_quarterly_pkey primary key(id)
);

create table staging.cash_flow_cn_insurance_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    net_income_starting_line varchar(100),
    depreciation_amortization varchar(100),
    non_cash_items varchar(100),
    net_cash_from_operating_activities varchar(100),
    change_in_fixed_assets_intangibles varchar(100),
    net_change_in_investments varchar(100),
    net_cash_from_investing_activities varchar(100),
    dividends_paid varchar(100),
    cash_from_repayment_of_debt varchar(100),
    cash_from_repurchase_of_equity varchar(100),
    net_cash_from_financing_activities varchar(100),
    effect_of_foreign_exchange_rate varchar(100),
    net_change_in_cash varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint cash_flow_cn_insurance_ttm_pkey primary key(id)
);

-- endregion China

-- endregion Cash Flow Tables

-- region Balance Sheet Tables

-- region USA

create table staging.balance_sheet_us_general_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    inventories varchar(100),
    total_current_assets varchar(100),
    property_plant_equipment varchar(100),
    long_term_investments_Receivables	 varchar(100),
    other_long_term_assets varchar(100),
    total_noncurrent_assets varchar(100),
    total_Assets varchar(100),
    payables_accruals varchar(100),
    short_term_debt varchar(100),
    total_current_liabilities varchar(100),
    long_term_debt varchar(100),
    total_noncurrent_liabilities varchar(100),
    total_liabilities varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_us_general_annual_pkey primary key(id)
);

create table staging.balance_sheet_us_general_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    inventories varchar(100),
    total_current_assets varchar(100),
    property_plant_equipment varchar(100),
    long_term_investments_Receivables	 varchar(100),
    other_long_term_assets varchar(100),
    total_noncurrent_assets varchar(100),
    total_Assets varchar(100),
    payables_accruals varchar(100),
    short_term_debt varchar(100),
    total_current_liabilities varchar(100),
    long_term_debt varchar(100),
    total_noncurrent_liabilities varchar(100),
    total_liabilities varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_us_general_quarterly_pkey primary key(id)
);

create table staging.balance_sheet_us_general_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    inventories varchar(100),
    total_current_assets varchar(100),
    property_plant_equipment varchar(100),
    long_term_investments_Receivables	 varchar(100),
    other_long_term_assets varchar(100),
    total_noncurrent_assets varchar(100),
    total_Assets varchar(100),
    payables_accruals varchar(100),
    short_term_debt varchar(100),
    total_current_liabilities varchar(100),
    long_term_debt varchar(100),
    total_noncurrent_liabilities varchar(100),
    total_liabilities varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_us_general_ttm_pkey primary key(id)
);

create table staging.balance_sheet_us_bank_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    interbank_assets varchar(100),
    short_long_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    net_loans varchar(100),
    net_fixed_Assets varchar(100),
    total_assets varchar(100),
    total_deposits varchar(100),
    short_term_Debt varchar(100),
    Long_term_debt varchar(100),
    Total_liabilities varchar(100),
    preferred_equity varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_us_bank_annual_pkey primary key(id)
);

create table staging.balance_sheet_us_bank_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    interbank_assets varchar(100),
    short_long_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    net_loans varchar(100),
    net_fixed_Assets varchar(100),
    total_assets varchar(100),
    total_deposits varchar(100),
    short_term_Debt varchar(100),
    Long_term_debt varchar(100),
    Total_liabilities varchar(100),
    preferred_equity varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_us_bank_quarterly_pkey primary key(id)
);

create table staging.balance_sheet_us_bank_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    interbank_assets varchar(100),
    short_long_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    net_loans varchar(100),
    net_fixed_Assets varchar(100),
    total_assets varchar(100),
    total_deposits varchar(100),
    short_term_Debt varchar(100),
    Long_term_debt varchar(100),
    Total_liabilities varchar(100),
    preferred_equity varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_us_bank_ttm_pkey primary key(id)
);

create table staging.balance_sheet_us_insurance_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    total_investments varchar(100),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    property_plant_equipment_net varchar(100),
    total_assets varchar(100),
    insurance_reserves varchar(100),
    short_term_debt varchar(100),
    long_term_debt varchar(100),
    total_liabilities varchar(100),
    preferred_equity varchar(100),
    policyholders_equity varchar(100),
    share_capital_additional_paid_in_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_us_insurance_annual_pkey primary key(id)
);

create table staging.balance_sheet_us_insurance_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    total_investments varchar(100),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    property_plant_equipment_net varchar(100),
    total_assets varchar(100),
    insurance_reserves varchar(100),
    short_term_debt varchar(100),
    long_term_debt varchar(100),
    total_liabilities varchar(100),
    preferred_equity varchar(100),
    policyholders_equity varchar(100),
    share_capital_additional_paid_in_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_us_insurance_quarterly_pkey primary key(id)
);

create table staging.balance_sheet_us_insurance_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    total_investments varchar(100),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    property_plant_equipment_net varchar(100),
    total_assets varchar(100),
    insurance_reserves varchar(100),
    short_term_debt varchar(100),
    long_term_debt varchar(100),
    total_liabilities varchar(100),
    preferred_equity varchar(100),
    policyholders_equity varchar(100),
    share_capital_additional_paid_in_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_us_insurance_ttm_pkey primary key(id)
);
    
-- endregion USA
   
-- region Germany

create table staging.balance_sheet_de_general_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    inventories varchar(100),
    total_current_assets varchar(100),
    property_plant_equipment varchar(100),
    long_term_investments_Receivables	 varchar(100),
    other_long_term_assets varchar(100),
    total_noncurrent_assets varchar(100),
    total_Assets varchar(100),
    payables_accruals varchar(100),
    short_term_debt varchar(100),
    total_current_liabilities varchar(100),
    long_term_debt varchar(100),
    total_noncurrent_liabilities varchar(100),
    total_liabilities varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_de_general_annual_pkey primary key(id)
);

create table staging.balance_sheet_de_general_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    inventories varchar(100),
    total_current_assets varchar(100),
    property_plant_equipment varchar(100),
    long_term_investments_Receivables	 varchar(100),
    other_long_term_assets varchar(100),
    total_noncurrent_assets varchar(100),
    total_Assets varchar(100),
    payables_accruals varchar(100),
    short_term_debt varchar(100),
    total_current_liabilities varchar(100),
    long_term_debt varchar(100),
    total_noncurrent_liabilities varchar(100),
    total_liabilities varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_de_general_quarterly_pkey primary key(id)
);

create table staging.balance_sheet_de_general_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    inventories varchar(100),
    total_current_assets varchar(100),
    property_plant_equipment varchar(100),
    long_term_investments_Receivables	 varchar(100),
    other_long_term_assets varchar(100),
    total_noncurrent_assets varchar(100),
    total_Assets varchar(100),
    payables_accruals varchar(100),
    short_term_debt varchar(100),
    total_current_liabilities varchar(100),
    long_term_debt varchar(100),
    total_noncurrent_liabilities varchar(100),
    total_liabilities varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_de_general_ttm_pkey primary key(id)
);

create table staging.balance_sheet_de_bank_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    interbank_assets varchar(100),
    short_long_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    net_loans varchar(100),
    net_fixed_Assets varchar(100),
    total_assets varchar(100),
    total_deposits varchar(100),
    short_term_Debt varchar(100),
    Long_term_debt varchar(100),
    Total_liabilities varchar(100),
    preferred_equity varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_de_bank_annual_pkey primary key(id)
);

create table staging.balance_sheet_de_bank_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    interbank_assets varchar(100),
    short_long_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    net_loans varchar(100),
    net_fixed_Assets varchar(100),
    total_assets varchar(100),
    total_deposits varchar(100),
    short_term_Debt varchar(100),
    Long_term_debt varchar(100),
    Total_liabilities varchar(100),
    preferred_equity varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_de_bank_quarterly_pkey primary key(id)
);

create table staging.balance_sheet_de_bank_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    interbank_assets varchar(100),
    short_long_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    net_loans varchar(100),
    net_fixed_Assets varchar(100),
    total_assets varchar(100),
    total_deposits varchar(100),
    short_term_Debt varchar(100),
    Long_term_debt varchar(100),
    Total_liabilities varchar(100),
    preferred_equity varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_de_bank_ttm_pkey primary key(id)
);

create table staging.balance_sheet_de_insurance_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    total_investments varchar(100),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    property_plant_equipment_net varchar(100),
    total_assets varchar(100),
    insurance_reserves varchar(100),
    short_term_debt varchar(100),
    long_term_debt varchar(100),
    total_liabilities varchar(100),
    preferred_equity varchar(100),
    policyholders_equity varchar(100),
    share_capital_additional_paid_in_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_de_insurance_annual_pkey primary key(id)
);

create table staging.balance_sheet_de_insurance_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    total_investments varchar(100),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    property_plant_equipment_net varchar(100),
    total_assets varchar(100),
    insurance_reserves varchar(100),
    short_term_debt varchar(100),
    long_term_debt varchar(100),
    total_liabilities varchar(100),
    preferred_equity varchar(100),
    policyholders_equity varchar(100),
    share_capital_additional_paid_in_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_de_insurance_quarterly_pkey primary key(id)
);

create table staging.balance_sheet_de_insurance_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    total_investments varchar(100),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    property_plant_equipment_net varchar(100),
    total_assets varchar(100),
    insurance_reserves varchar(100),
    short_term_debt varchar(100),
    long_term_debt varchar(100),
    total_liabilities varchar(100),
    preferred_equity varchar(100),
    policyholders_equity varchar(100),
    share_capital_additional_paid_in_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_de_insurance_ttm_pkey primary key(id)
);

-- endregion Germany

-- region China

create table staging.balance_sheet_cn_general_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    inventories varchar(100),
    total_current_assets varchar(100),
    property_plant_equipment varchar(100),
    long_term_investments_Receivables	 varchar(100),
    other_long_term_assets varchar(100),
    total_noncurrent_assets varchar(100),
    total_Assets varchar(100),
    payables_accruals varchar(100),
    short_term_debt varchar(100),
    total_current_liabilities varchar(100),
    long_term_debt varchar(100),
    total_noncurrent_liabilities varchar(100),
    total_liabilities varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_cn_general_annual_pkey primary key(id)
);

create table staging.balance_sheet_cn_general_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    inventories varchar(100),
    total_current_assets varchar(100),
    property_plant_equipment varchar(100),
    long_term_investments_Receivables	 varchar(100),
    other_long_term_assets varchar(100),
    total_noncurrent_assets varchar(100),
    total_Assets varchar(100),
    payables_accruals varchar(100),
    short_term_debt varchar(100),
    total_current_liabilities varchar(100),
    long_term_debt varchar(100),
    total_noncurrent_liabilities varchar(100),
    total_liabilities varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_cn_general_quarterly_pkey primary key(id)
);

create table staging.balance_sheet_cn_general_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    inventories varchar(100),
    total_current_assets varchar(100),
    property_plant_equipment varchar(100),
    long_term_investments_Receivables	 varchar(100),
    other_long_term_assets varchar(100),
    total_noncurrent_assets varchar(100),
    total_Assets varchar(100),
    payables_accruals varchar(100),
    short_term_debt varchar(100),
    total_current_liabilities varchar(100),
    long_term_debt varchar(100),
    total_noncurrent_liabilities varchar(100),
    total_liabilities varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_cn_general_ttm_pkey primary key(id)
);

create table staging.balance_sheet_cn_bank_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    interbank_assets varchar(100),
    short_long_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    net_loans varchar(100),
    net_fixed_Assets varchar(100),
    total_assets varchar(100),
    total_deposits varchar(100),
    short_term_Debt varchar(100),
    Long_term_debt varchar(100),
    Total_liabilities varchar(100),
    preferred_equity varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_cn_bank_annual_pkey primary key(id)
);

create table staging.balance_sheet_cn_bank_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    interbank_assets varchar(100),
    short_long_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    net_loans varchar(100),
    net_fixed_Assets varchar(100),
    total_assets varchar(100),
    total_deposits varchar(100),
    short_term_Debt varchar(100),
    Long_term_debt varchar(100),
    Total_liabilities varchar(100),
    preferred_equity varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_cn_bank_quarterly_pkey primary key(id)
);

create table staging.balance_sheet_cn_bank_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    cash_cash_equivalents_short_term_investments varchar(100),
    interbank_assets varchar(100),
    short_long_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    net_loans varchar(100),
    net_fixed_Assets varchar(100),
    total_assets varchar(100),
    total_deposits varchar(100),
    short_term_Debt varchar(100),
    Long_term_debt varchar(100),
    Total_liabilities varchar(100),
    preferred_equity varchar(100),
    share_capital_additional_paid_In_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_cn_bank_ttm_pkey primary key(id)
);

create table staging.balance_sheet_cn_insurance_annual
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    total_investments varchar(100),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    property_plant_equipment_net varchar(100),
    total_assets varchar(100),
    insurance_reserves varchar(100),
    short_term_debt varchar(100),
    long_term_debt varchar(100),
    total_liabilities varchar(100),
    preferred_equity varchar(100),
    policyholders_equity varchar(100),
    share_capital_additional_paid_in_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_cn_insurance_annual_pkey primary key(id)
);

create table staging.balance_sheet_cn_insurance_quarterly
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    total_investments varchar(100),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    property_plant_equipment_net varchar(100),
    total_assets varchar(100),
    insurance_reserves varchar(100),
    short_term_debt varchar(100),
    long_term_debt varchar(100),
    total_liabilities varchar(100),
    preferred_equity varchar(100),
    policyholders_equity varchar(100),
    share_capital_additional_paid_in_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_cn_insurance_quarterly_pkey primary key(id)
);

create table staging.balance_sheet_cn_insurance_ttm
(
    id serial not null,
    ticker varchar(20),
    sim_fin_id varchar(20),
    currency char(3),
    fiscal_year char(4),
    fiscal_period char(2),
    report_date varchar(10),
    publish_date varchar(10),
    restated_date varchar(10),
    shares_basic varchar(40),
    shares_diluted varchar(40),
    total_investments varchar(100),
    cash_cash_equivalents_short_term_investments varchar(100),
    accounts_notes_receivable varchar(100),
    property_plant_equipment_net varchar(100),
    total_assets varchar(100),
    insurance_reserves varchar(100),
    short_term_debt varchar(100),
    long_term_debt varchar(100),
    total_liabilities varchar(100),
    preferred_equity varchar(100),
    policyholders_equity varchar(100),
    share_capital_additional_paid_in_capital varchar(100),
    treasury_stock varchar(100),
    retained_earnings varchar(100),
    total_equity varchar(100),
    total_liabilities_equity varchar(100),
    created_on timestamp with time zone not null default current_timestamp,
    constraint balance_sheet_cn_insurance_ttm_pkey primary key(id)
);

-- endregion

-- endregion Balance Sheet Tables
    
-- endregion Staging Schema - Tables

-- region Logging Code

create or replace function staging.fn_log_info_id()
    returns smallint
as $body$
declare
    type_id smallint;
begin
    select id into type_id from staging.log_message_type where (message_name = 'Info');
    return type_id;
end;
$body$ language plpgsql;

create or replace function staging.fn_log_warn_id()
    returns smallint
AS $body$
declare
    type_id smallint;
begin
    select id into type_id from staging.log_message_type where (message_name = 'Warn');
    return type_id;
end;
$body$ language plpgsql;

create or replace function staging.fn_log_error_id()
    returns smallint
AS $body$
declare
    type_id smallint;
begin
    select id into type_id from staging.log_message_type where (message_name = 'Error');
    return type_id;
end;
$body$ language plpgsql;

create or replace function staging.fn_log_debug_id()
    returns smallint
AS $body$
declare
    type_id smallint;
begin
    select id into type_id from staging.log_message_type where (message_name = 'Debug');
    return type_id;
end;
$body$ language plpgsql;

create or replace procedure staging.sp_log_info(IN log_message varchar)
AS $body$
begin
    insert into staging.log(message, message_type_id) values (log_message, staging.fn_log_info_id());
end;
$body$ language plpgsql;

create or replace procedure staging.sp_log_warn(IN log_message varchar)
AS $body$
begin
    insert into staging.log(message, message_type_id) values (log_message, staging.fn_log_warn_id());
end;
$body$ language plpgsql;

create or replace procedure staging.sp_log_error(IN log_message varchar)
AS $body$
begin
    insert into staging.log(message, message_type_id) values (log_message, staging.fn_log_error_id());
end;
$body$ language plpgsql;

create or replace procedure staging.sp_log_debug(IN log_message varchar)
AS $body$
begin
    insert into staging.log(message, message_type_id) values (log_message, staging.fn_log_debug_id());
end;
$body$ language plpgsql;

-- endregion Logging Code