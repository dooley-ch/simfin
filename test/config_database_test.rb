# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     config_database_test.rb
# ╠═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Created: 03.02.2025
# ║
# ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
# ║
# ║     History:
# ║     03.02.2025: Initial version
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/config'

class ConfigDatabaseTest < Minitest::Test
  # rubocop : disable Minitest/MultipleAssertions
  def test_should_return_database_info
    info = Config::Database.call

    refute_nil info, 'Information not loaded'
    assert_equal 'simfin', info.database, 'Incorrect database name returned'
    assert_equal 'simfin_dev_user', info.user, 'Incorrect user name returned'
    assert_equal 'dev#123', info.password, 'Incorrect password returned'
  end
  # rubocop : enable Minitest/MultipleAssertions
end
