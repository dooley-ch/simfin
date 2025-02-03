# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     config_logging_test.rb
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

class ConfigLoggingTest < Minitest::Test
  def test_should_return_logging_info
    info = Config::Logging.call

    refute_nil info, 'Information not loaded'
    assert_equal 'debug', info.level, 'Incorrect logging level returned'
    assert_equal 'simfin.log', info.file, 'Incorrect file name returned'
  end
end
