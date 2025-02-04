# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     verify_tasks.rake
# ╠═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Created: 03.02.2025
# ║
# ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
# ║
# ║     History:
# ║     03.02.2025: Initial version
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
# frozen_string_literal: true

require 'tty-logger'
require_relative '../lib/verify_task_helpers'

namespace :verify_tasks do
  task :all, [:section] do |_, args|
    verify_type = args[:section].to_sym

    if (console_logger = TTY::Logger.new)
      case verify_type
      when :simfin
        console_logger.info 'Verifying simfin config'
      when :logging
        console_logger.info 'Verifying logging config'
      when :database
        console_logger.info 'Verifying database'
      else
        console_logger.info 'Verifying all'
      end
    end
  end
end
