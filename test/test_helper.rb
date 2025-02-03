# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     test_helper.rb
# ╠═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Created: 26.01.2025
# ║
# ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
# ║
# ║     History:
# ║     26.01.2025: Initial version
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
# frozen_string_literal: true

require 'minitest/autorun'
require 'pathname'

module TestHelpers
  def base_data_folder
    Pathname.new(__FILE__).dirname.dirname.join('data')
  end

  def root_folder
    Pathname.new(__FILE__).dirname.dirname
  end

  # def set_environment_variables
  #   base_folder = Pathname(__FILE__).dirname.dirname
  #   config_folder = base_folder.join('config')
  #   data_folder = base_folder.join('data')
  #
  #   ENV['Config_Folder'] = config_folder.realpath.to_s
  #   ENV['Data_Root_Folder'] = data_folder.realpath.to_s
  # end
end
