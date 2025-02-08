# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     import_tasks.rb
# ╠═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Created: 05.02.2025
# ║
# ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
# ║
# ║     History:
# ║     05.02.2025: Initial version
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
# frozen_string_literal: true

require 'zip'
require 'tty-spinner'

namespace :import_tasks do # rubocop : disable Metrics/BlockLength
  task all: %i[unzip_files import_other_files import_company_files import_share_price_files import_income_statements
               import_cashflow_statements import_balance_sheets]

  task :unzip_files do
    spinner = TTY::Spinner.new('[:spinner] Unzipping files ...', format: :shark)
    spinner.auto_spin

    temp_folder = Config::Folders.temp
    zip_files = FileList.new("#{Config::Folders.downloads}/*.zip")

    unzipped_files = 0
    zip_files.each do |zip_file|
      Zip::File.open(zip_file) do |file|
        file.each do |csv_file|
          unziped_file = Pathname.new(temp_folder).join(csv_file.name)
          FileUtils.rm_rf(unziped_file)

          csv_file.extract(unziped_file.to_s)

          unzipped_files += 1
          LOGGER.debug("File unzipped: #{unziped_file}")
        end
      end
    end

    LOGGER.info("Total unzipped files: #{unzipped_files}")

    spinner.stop('Done')
  end

  task :import_other_files do
    spinner = TTY::Spinner.new('[:spinner] Importing markets and industries files ...', format: :shark)
    spinner.auto_spin

    file_names = SimFinNameBuilder.others(:csv, LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    # Import markets table
    file = file_names[:markets]

    query = %{
      COPY staging.markets (market_id, market_name, currency)  FROM '#{temp_folder}/#{file}'
      DELIMITER ';' HEADER csv;
    }

    DatabaseHelpers.import_table('markets', query, db_info, LOGGER)
    LOGGER.info('Markets file imported')

    # Import industries table
    file = file_names[:industries]

    query = %{
      COPY staging.industries (industry_id, industry, sector)  FROM '#{temp_folder}/#{file}'
      DELIMITER ';' HEADER csv;
    }

    DatabaseHelpers.import_table('industries', query, db_info, LOGGER)
    LOGGER.info('Industries file imported')

    spinner.stop('Done')
  end

  task :import_company_files do
    spinner = TTY::Spinner.new('[:spinner] Importing company files ...', format: :shark)
    spinner.auto_spin

    file_names = SimFinNameBuilder.companies(:csv, LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    file_names.each do |key, file|
      table_name = "company_#{key}"

      query = %{
        COPY staging.#{table_name} (ticker, sim_fin_id, company_name, industry_id, isin,
            end_of_financial_year_month, number_employees, business_summary, market, cik, main_currency)
        FROM '#{temp_folder}/#{file}' DELIMITER ';' HEADER csv;
      }

      DatabaseHelpers.import_table(table_name, query, db_info, LOGGER)
      LOGGER.info("#{table_name} file imported")

      spinner.stop('Done')
    end
  end

  task :import_share_price_files do
    spinner = TTY::Spinner.new('[:spinner] Importing share price files ...', format: :shark)
    spinner.auto_spin

    file_names = SimFinNameBuilder.share_prices(:csv, LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    file_names.each do |key, file|
      table_name = "share_prices_#{key}"

      query = %{
        COPY staging.#{table_name} (ticker, sim_fin_id, price_date, open_price, high_price, low_price, close_price,
                                      adj_close_price, volume, dividend, shares_outstanding)
        FROM '#{temp_folder}/#{file}' DELIMITER ';' HEADER csv;
      }

      DatabaseHelpers.import_table(table_name, query, db_info, LOGGER)
      LOGGER.info("#{table_name} file imported")

      spinner.stop('Done')
    end
  end

  task import_income_statements: %i[import_general_income_files import_bank_income_files import_insurance_income_files]

  task :import_general_income_files do
    spinner = TTY::Spinner.new('[:spinner] Importing general income files ...', format: :shark)
    spinner.auto_spin

    regions = SimFinNameBuilder.regions(LOGGER)
    time_frames = SimFinNameBuilder.time_frames(LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    regions.each do |region|
      time_frames.each do |time_frame|
        table_name = "income_statement_#{region}_general_#{time_frame}"
        file_name = "#{region}-income-#{time_frame}.csv"

        query = %{
          COPY staging.#{table_name} (ticker, sim_fin_id, currency, fiscal_year, fiscal_period, report_date,
                                      publish_date, restated_date, shares_basic, shares_diluted, revenue,
                                      cost_of_revenue, gross_profit, operating_expenses,
                                      selling_general_administrative, research_development,
                                      depreciation_amortization, operating_income_loss,
                                      non_operating_income_loss, interest_expense_net, pretax_income_loss_adj,
                                      abnormal_gains_losses, pretax_income_loss, income_tax_expense_benefit_net,
                                      income_loss_from_continuing_operations, net_extraordinary_gains_losses,
                                      net_income, net_income_common)
          FROM '#{temp_folder}/#{file_name}' DELIMITER ';' HEADER csv;
        }

        DatabaseHelpers.import_table(table_name, query, db_info, LOGGER)
        LOGGER.info("Income #{table_name} file imported")
      end
    end

    spinner.stop('Done')
  end

  task :import_bank_income_files do
    spinner = TTY::Spinner.new('[:spinner] Importing bank income files ...', format: :shark)
    spinner.auto_spin

    regions = SimFinNameBuilder.regions(LOGGER)
    time_frames = SimFinNameBuilder.time_frames(LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    regions.each do |region|
      time_frames.each do |time_frame|
        table_name = "income_statement_#{region}_bank_#{time_frame}"
        file_name = "#{region}-income-banks-#{time_frame}.csv"

        query = %{
            COPY staging.#{table_name} (ticker, sim_fin_id, currency, fiscal_year, fiscal_period,
                                      report_date, publish_date, restated_date, shares_basic, shares_diluted, revenue,
                                      provision_for_loan_losses, net_revenue_after_provisions,
                                      total_non_interest_expense, operating_income_loss,
                                      non_operating_income_loss, pretax_income_loss, income_tax_expense_benefit_net,
                                      income_loss_from_continuing_operations, net_extraordinary_gains_losses,
                                      net_income, net_income_common)
            FROM '#{temp_folder}/#{file_name}' DELIMITER ';' HEADER csv;
          }

        DatabaseHelpers.import_table(table_name, query, db_info, LOGGER)
        LOGGER.info("Income #{table_name} file imported")
      end
    end

    spinner.stop('Done')
  end

  task :import_insurance_income_files do
    spinner = TTY::Spinner.new('[:spinner] Importing insurance income files ...', format: :shark)
    spinner.auto_spin

    regions = SimFinNameBuilder.regions(LOGGER)
    time_frames = SimFinNameBuilder.time_frames(LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    regions.each do |region|
      time_frames.each do |time_frame|
        table_name = "income_statement_#{region}_insurance_#{time_frame}"
        file_name = "#{region}-income-insurance-#{time_frame}.csv"

        query = %{
          COPY staging.#{table_name} (ticker, sim_fin_id, currency, fiscal_year, fiscal_period, report_date,
                                      publish_date, restated_date, shares_basic, shares_diluted, revenue,
                                      total_claims_losses, operating_income_loss, pretax_income_loss,
                                      income_tax_expense_benefit_net, income_loss_from_affiliates_net_of_taxes,
                                      income_loss_from_continuing_operations, net_extraordinary_gains_losses,
                                      net_income, net_income_common)
          FROM '#{temp_folder}/#{file_name}' DELIMITER ';' HEADER csv;
        }

        DatabaseHelpers.import_table(table_name, query, db_info, LOGGER)
        LOGGER.info("Income #{table_name} file imported")
      end
    end

    spinner.stop('Done')
  end

  task import_cashflow_statements: %i[import_general_cashflow_files import_bank_cashflow_files
                                      import_insurance_cashflow_files]

  task :import_general_cashflow_files do
    spinner = TTY::Spinner.new('[:spinner] Importing general cashflow files ...', format: :shark)
    spinner.auto_spin

    regions = SimFinNameBuilder.regions(LOGGER)
    time_frames = SimFinNameBuilder.time_frames(LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    regions.each do |region|
      time_frames.each do |time_frame|
        table_name = "cash_flow_#{region}_general_#{time_frame}"
        file_name = "#{region}-cashflow-#{time_frame}.csv"

        query = %{
          COPY staging.#{table_name} (ticker, sim_fin_id, currency, fiscal_year, fiscal_period, report_date,
                                      publish_date, restated_date, shares_basic, shares_diluted,
                                      net_income_starting_line, depreciation_amortization, non_cash_items,
                                      change_in_working_capital, change_in_accounts_receivable, change_in_inventories,
                                      change_in_accounts_payable, change_in_other, net_cash_from_operating_activities,
                                      change_in_fixed_assets_intangibles, net_change_in_long_term_investment,
                                      net_cash_from_acquisitions_divestitures, net_cash_from_investing_activities,
                                      dividends_paid, cash_from_repayment_of_debt, cash_from_repurchase_of_equity,
                                      net_cash_from_financing_activities, net_change_in_cash)
          FROM '#{temp_folder}/#{file_name}' DELIMITER ';' HEADER csv;
        }

        DatabaseHelpers.import_table(table_name, query, db_info, LOGGER)
        LOGGER.info("Cashflow #{table_name} file imported")
      end
    end

    spinner.stop('Done')
  end

  task :import_bank_cashflow_files do
    spinner = TTY::Spinner.new('[:spinner] Importing bank cashflow files ...', format: :shark)
    spinner.auto_spin

    regions = SimFinNameBuilder.regions(LOGGER)
    time_frames = SimFinNameBuilder.time_frames(LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    regions.each do |region|
      time_frames.each do |time_frame|
        table_name = "cash_flow_#{region}_bank_#{time_frame}"
        file_name = "#{region}-cashflow-banks-#{time_frame}.csv"

        query = %{
          COPY staging.#{table_name} (ticker, sim_fin_id, currency, fiscal_year, fiscal_period, report_date,
                                      publish_date, restated_date, shares_basic, shares_diluted,
                                      net_income_starting_line, depreciation_amortization, provision_for_loan_losses,
                                      non_cash_items, change_in_working_capital, net_cash_from_operating_activities,
                                      change_in_fixed_assets_intangibles, net_change_in_loans_interbank,
                                      net_cash_from_acquisitions_divestitures, net_cash_from_investing_activities,
                                      dividends_paid, cash_from_repayment_of_debt, cash_from_repurchase_of_equity,
                                      net_cash_from_financing_activities, effect_of_foreign_exchange_rates,
                                      net_change_in_cash)
          FROM '#{temp_folder}/#{file_name}' DELIMITER ';' HEADER csv;
        }

        DatabaseHelpers.import_table(table_name, query, db_info, LOGGER)
        LOGGER.info("Cashflow #{table_name} file imported")
      end
    end

    spinner.stop('Done')
  end

  task :import_insurance_cashflow_files do
    spinner = TTY::Spinner.new('[:spinner] Importing insurance cashflow files ...', format: :shark)
    spinner.auto_spin

    regions = SimFinNameBuilder.regions(LOGGER)
    time_frames = SimFinNameBuilder.time_frames(LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    regions.each do |region|
      time_frames.each do |time_frame|
        table_name = "cash_flow_#{region}_insurance_#{time_frame}"
        file_name = "#{region}-cashflow-insurance-#{time_frame}.csv"

        query = %{
          COPY staging.#{table_name} (ticker, sim_fin_id, currency, fiscal_year, fiscal_period, report_date,
                                      publish_date, restated_date, shares_basic, shares_diluted,
                                      net_income_starting_line,
                                      depreciation_amortization, non_cash_items, net_cash_from_operating_activities,
                                      change_in_fixed_assets_intangibles, net_change_in_investments,
                                      net_cash_from_investing_activities,
                                      dividends_paid, cash_from_repayment_of_debt, cash_from_repurchase_of_equity,
                                      net_cash_from_financing_activities, effect_of_foreign_exchange_rate,
                                      net_change_in_cash)
          FROM '#{temp_folder}/#{file_name}' DELIMITER ';' HEADER csv;
        }

        DatabaseHelpers.import_table(table_name, query, db_info, LOGGER)
        LOGGER.info("Cashflow #{table_name} file imported")
      end
    end

    spinner.stop('Done')
  end

  task import_balance_sheets: %i[import_general_balance_sheet_files import_bank_balance_sheet_files
                                 import_insurance_balance_sheet_files]

  task :import_general_balance_sheet_files do
    spinner = TTY::Spinner.new('[:spinner] Importing general balance sheet files ...', format: :shark)
    spinner.auto_spin

    regions = SimFinNameBuilder.regions(LOGGER)
    time_frames = SimFinNameBuilder.time_frames(LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    regions.each do |region|
      time_frames.each do |time_frame|
        table_name = "balance_sheet_#{region}_general_#{time_frame}"
        file_name = "#{region}-balance-#{time_frame}.csv"

        query = %{
          COPY staging.#{table_name} (ticker, sim_fin_id, currency, fiscal_year, fiscal_period, report_date,
                                      publish_date, restated_date, shares_basic, shares_diluted,
                                      cash_cash_equivalents_short_term_investments, accounts_notes_receivable,
                                      inventories, total_current_assets, property_plant_equipment,
                                      long_term_investments_receivables, other_long_term_assets,
                                      total_noncurrent_assets, total_assets, payables_accruals, short_term_debt,
                                      total_current_liabilities, long_term_debt, total_noncurrent_liabilities,
                                      total_liabilities, share_capital_additional_paid_in_capital, treasury_stock,
                                      retained_earnings, total_equity, total_liabilities_equity)
          FROM '#{temp_folder}/#{file_name}' DELIMITER ';' HEADER csv;
        }

        DatabaseHelpers.import_table(table_name, query, db_info, LOGGER)
        LOGGER.info("Balance sheet #{table_name} file imported")
      end
    end

    spinner.stop('Done')
  end

  task :import_bank_balance_sheet_files do
    spinner = TTY::Spinner.new('[:spinner] Importing bank balance sheet files ...', format: :shark)
    spinner.auto_spin

    regions = SimFinNameBuilder.regions(LOGGER)
    time_frames = SimFinNameBuilder.time_frames(LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    regions.each do |region|
      time_frames.each do |time_frame|
        table_name = "balance_sheet_#{region}_bank_#{time_frame}"
        file_name = "#{region}-balance-banks-#{time_frame}.csv"

        query = %{
          COPY staging.#{table_name} (ticker, sim_fin_id, currency, fiscal_year, fiscal_period, report_date,
                                      publish_date, restated_date, shares_basic, shares_diluted,
                                      cash_cash_equivalents_short_term_investments, interbank_assets,
                                      short_long_term_investments, accounts_notes_receivable, net_loans,
                                      net_fixed_assets, total_assets, total_deposits, short_term_debt, long_term_debt,
                                      total_liabilities, preferred_equity, share_capital_additional_paid_in_capital,
                                      treasury_stock, retained_earnings, total_equity, total_liabilities_equity)
          FROM '#{temp_folder}/#{file_name}' DELIMITER ';' HEADER csv;
        }

        DatabaseHelpers.import_table(table_name, query, db_info, LOGGER)
        LOGGER.info("Balance sheet #{table_name} file imported")
      end
    end

    spinner.stop('Done')
  end

  task :import_insurance_balance_sheet_files do
    spinner = TTY::Spinner.new('[:spinner] Importing insurance balance sheet files ...', format: :shark)
    spinner.auto_spin

    regions = SimFinNameBuilder.regions(LOGGER)
    time_frames = SimFinNameBuilder.time_frames(LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    regions.each do |region|
      time_frames.each do |time_frame|
        table_name = "balance_sheet_#{region}_insurance_#{time_frame}"
        file_name = "#{region}-balance-insurance-#{time_frame}.csv"

        query = %{
          COPY staging.#{table_name} (ticker, sim_fin_id, currency, fiscal_year, fiscal_period, report_date,
                                      publish_date, restated_date, shares_basic,
                                      shares_diluted, total_investments, cash_cash_equivalents_short_term_investments,
                                      accounts_notes_receivable,
                                      property_plant_equipment_net, total_assets, insurance_reserves, short_term_debt,
                                      long_term_debt, total_liabilities, preferred_equity, policyholders_equity,
                                      share_capital_additional_paid_in_capital,
                                      treasury_stock, retained_earnings, total_equity, total_liabilities_equity)
          FROM '#{temp_folder}/#{file_name}' DELIMITER ';' HEADER csv;
        }

        DatabaseHelpers.import_table(table_name, query, db_info, LOGGER)
        LOGGER.info("Balance sheet #{table_name} file imported")
      end
    end

    spinner.stop('Done')
  end
end
