# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     config_files_test.rb
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

class ConfigFilesTest < Minitest::Test
  include TestHelpers

  def test_should_return_log_file_name
    target_file = base_data_folder.join('logs', 'simfin.log')
    file = Config::Files.log_file

    assert_equal target_file, file, 'Incorrect log file name'
  end

  def test_should_return_config_file_name
    target_file = root_folder.join('config.yml')
    file = Config::Files.config_file

    assert_equal target_file, file, 'Incorrect config file name'
  end
end
