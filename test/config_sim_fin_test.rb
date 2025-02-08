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
  def test_should_return_array_of_regions
    info = Config::SimFin.call

    refute_nil info, 'No SimFin information returned'

    assert_kind_of Array, info.regions
  end

  def test_should_return_array_of_time_frames
    info = Config::SimFin.call

    refute_nil info, 'No SimFin information returned'

    assert_kind_of Array, info.time_frames
  end

  def test_should_return_array_of_companies
    info = Config::SimFin.call

    refute_nil info, 'No SimFin information returned'

    assert_kind_of Array, info.companies
  end

  def test_should_return_array_of_others
    info = Config::SimFin.call

    refute_nil info, 'No SimFin information returned'

    assert_kind_of Array, info.others
  end
end
