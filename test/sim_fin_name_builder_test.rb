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

# rubocop : disable Minitest/MultipleAssertions
class SimFinNameBuilderTest < Minitest::Test
  def test_should_return_all_file_names
    names = SimFinNameBuilder.all

    assert_instance_of Array, names
    refute_empty names
    assert_includes names, 'markets.zip'
    assert_includes names, 'industries.zip'
  end

  def test_should_return_other_files
    names = SimFinNameBuilder.others

    assert_instance_of Hash, names
    refute_empty names
    assert names.key? :markets
    assert names.key? :industries
  end

  def test_should_return_company_files
    names = SimFinNameBuilder.companies

    assert_instance_of Hash, names
    refute_empty names
    assert names.key? :us
    assert names.key? :de
    assert names.key? :cn
  end
end
# rubocop : enable Minitest/MultipleAssertions
