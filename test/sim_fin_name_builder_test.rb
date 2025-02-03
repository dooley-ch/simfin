# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     sim_fin_name_builder_test.rb
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
require_relative '../lib/sim_fin_name_builder'

class SimFinNameBuilderTest < Minitest::Test
  def test_should_return_all_file_names
    names = SimFinNameBuilder.all

    assert_instance_of Array, names
    refute_empty names
    assert_includes names, 'markets.zip'
    assert_includes names, 'industries.zip'
  end
end
