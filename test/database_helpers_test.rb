# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     database_helpers_test.rb
# ╠═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Created: 06.02.2025
# ║
# ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
# ║
# ║     History:
# ║     06.02.2025: Initial version
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/config'
require_relative '../lib/database_helpers'
require_relative '../lib/sim_fin_name_builder'

class DatabaseHelpersTest < Minitest::Test
  include TestHelpers

  def test_import_file # rubocop : disable Metrics/MethodLength
    db_conn_info = Config::Database.call
    temp_folder = Config::Folders.temp
    other_file_names = SimFinNameBuilder.others(:csv)
    markets_file = other_file_names[:markets]

    query = %{
      COPY staging.markets (market_id, market_name, currency)  FROM '#{temp_folder}/#{markets_file}'
      DELIMITER ';' HEADER csv;
    }

    assert_silent do
      DatabaseHelpers.import_table('markets', query, db_conn_info)
    end
  end
end
