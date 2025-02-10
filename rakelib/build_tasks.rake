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

namespace :build_tasks do
  task all: %i[reset_public_tables build_stock_market_table build_sector_table build_industry_table]

  task :reset_public_tables do
    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_reset_public_tables', db_info, LOGGER)
  end

  task :build_stock_market_table do
    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_stock_market_table', db_info, LOGGER)
  end

  task :build_sector_table do
    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_sector_table', db_info, LOGGER)
  end

  task :build_industry_table do
    db_info = Config::Database.call(LOGGER)

    DatabaseHelpers.execute_stored_procedure('sp_build_industry_table', db_info, LOGGER)
  end
end
