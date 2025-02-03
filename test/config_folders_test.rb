# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     config_folders_test.rb
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

class ConfigFoldersTest < Minitest::Test
  include TestHelpers

  def test_should_return_logs_folder
    target_folder = base_data_folder.join 'logs'
    logs_folder = Config::Folders.logs

    assert_equal target_folder.to_s, logs_folder, 'Incorrect logs folder returned'
    assert_path_exists logs_folder, 'Logs folder not found'
  end

  def test_should_return_downloads_folder
    target_folder = base_data_folder.join 'downloads'
    logs_folder = Config::Folders.downloads

    assert_equal target_folder.to_s, logs_folder, 'Incorrect downloads folder returned'
    assert_path_exists logs_folder, 'Downloads folder not found'
  end

  def test_should_return_temp_folder
    target_folder = base_data_folder.join 'temp'
    logs_folder = Config::Folders.temp

    assert_equal target_folder.to_s, logs_folder, 'Incorrect temp folder returned'
    assert_path_exists logs_folder, 'Temp folder not found'
  end

  def test_should_return_archive_folder
    target_folder = base_data_folder.join 'archive'
    logs_folder = Config::Folders.archive

    assert_equal target_folder.to_s, logs_folder, 'Incorrect archive folder returned'
    assert_path_exists logs_folder, 'Archive folder not found'
  end
end
