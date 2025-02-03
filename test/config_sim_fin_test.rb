# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     config_sim_fin_test.rb
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

class ConfigSimFinTest < Minitest::Test
  def test_should_return_database_info
    info = Config::SimFin.call

    refute_nil info, 'No SimFin information returned'

    assert_kind_of Array, info.regions
    assert_kind_of Array, info.time_frames
    assert_kind_of Array, info.companies
    assert_kind_of Array, info.others
  end
end
