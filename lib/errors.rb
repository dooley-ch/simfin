# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     errors.rb
# ╠═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Created: 03.02.2025
# ║
# ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
# ║
# ║     History:
# ║     03.02.2025: Initial version
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
# frozen_string_literal: true

# This module holds the application specific error classes
module Errors
  # This error class is raised when the application is unable to find
  # a required file
  class FileNotFoundError < StandardError
    attr_reader :file_name

    # @param [string, _ToS] file_name - the name of the missing file
    def initialize(file_name)
      super("File not found: #{file_name}")
      @file_name = file_name
    end
  end

  # This error class is raised when the application finds
  # an error in the configuration information
  class ConfigurationError < StandardError
    # @param [string, _ToS] message - the configuration error message
    def initialize(message)
      super("Configuration error: #{message}")
    end
  end
end
