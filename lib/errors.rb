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

module Errors
  class FileNotFoundError < StandardError
    attr_reader :file_name

    def initialize(file_name)
      super("File not found: #{file_name}")
      @file_name = file_name
    end
  end

  class ConfigurationError < StandardError
    def initialize(message)
      super("Configuration error: #{message}")
    end
  end
end
