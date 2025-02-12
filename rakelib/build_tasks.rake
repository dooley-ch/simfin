# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     build_tasks.rake
# ╠═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Created: 10.02.2025
# ║
# ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
# ║
# ║     History:
# ║     10.02.2025: Initial version
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
# frozen_string_literal: true

require 'tty-spinner'

namespace :build_tasks do # rubocop : disable Metrics/BlockLength
  task all: %i[reset_public_tables build_stock_market_table build_sector_table build_industry_table build_company_table
               build_income_tables build_cashflow_tables]

  task :reset_public_tables do
    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_reset_public_tables', db_info, LOGGER)
  end

  task :build_stock_market_table do
    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_stock_market_table', db_info, LOGGER)

    LOGGER.info('Stock Market table built')
  end

  task :build_sector_table do
    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_sector_table', db_info, LOGGER)

    LOGGER.info('Sector table built')
  end

  task :build_industry_table do
    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_industry_table', db_info, LOGGER)

    LOGGER.info('Industry table built')
  end

  task :build_company_table do
    spinner = TTY::Spinner.new('[:spinner] Building company table ...', format: :shark)
    spinner.auto_spin

    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_company_table', db_info, LOGGER)

    LOGGER.info('Company table built')

    spinner.stop('Done')
  end

  task build_income_tables: %i[build_income_table_standard_table build_income_table_bank_table
                               build_income_table_insurance_table]

  task :build_income_table_standard_table do
    spinner = TTY::Spinner.new('[:spinner] Building income table (general) ...', format: :shark)
    spinner.auto_spin

    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_income_statement__general_table', db_info, LOGGER)

    LOGGER.info('Income table (general) table built')

    spinner.stop('Done')
  end

  task :build_income_table_bank_table do
    spinner = TTY::Spinner.new('[:spinner] Building income table (bank) ...', format: :shark)
    spinner.auto_spin

    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_income_statement__bank_table', db_info, LOGGER)

    LOGGER.info('Income table (bank) table built')

    spinner.stop('Done')
  end

  task :build_income_table_insurance_table do
    spinner = TTY::Spinner.new('[:spinner] Building income table (insurance) ...', format: :shark)
    spinner.auto_spin

    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_income_statement_insurance_table', db_info, LOGGER)

    LOGGER.info('Income table (insurance) table built')

    spinner.stop('Done')
  end

  task build_cashflow_tables: %i[build_cashflow_table_general_table build_cashflow_table_bank_table
                                 build_cashflow_table_insurance_table]

  task :build_cashflow_table_general_table do
    spinner = TTY::Spinner.new('[:spinner] Building cashflow table (general) ...', format: :shark)
    spinner.auto_spin

    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_cashflow_general_table', db_info, LOGGER)

    LOGGER.info('Cashflow table (general) table built')

    spinner.stop('Done')
  end

  task :build_cashflow_table_bank_table do
    spinner = TTY::Spinner.new('[:spinner] Building cashflow table (bank) ...', format: :shark)
    spinner.auto_spin

    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_cashflow_bank_table', db_info, LOGGER)

    LOGGER.info('Cashflow table (bank) table built')

    spinner.stop('Done')
  end

  task :build_cashflow_table_insurance_table do
    spinner = TTY::Spinner.new('[:spinner] Building cashflow table (insurance) ...', format: :shark)
    spinner.auto_spin

    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_cashflow_insurance_table', db_info, LOGGER)

    LOGGER.info('Cashflow table (insurance) table built')

    spinner.stop('Done')
  end
end
