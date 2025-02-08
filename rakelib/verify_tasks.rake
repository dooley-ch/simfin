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

require_relative '../lib/verify_task_helpers'

namespace :verify_tasks do
  task :all, [:section] do |_, args|
    verify_type = args[:section].to_sym

    case verify_type
    when :simfin
      VerifyTaskHelpers::SimFin.call(LOGGER)
    when :logging
      VerifyTaskHelpers::Logging.call(LOGGER)
    when :database
      VerifyTaskHelpers::Database.call(LOGGER)
    when :files
      VerifyTaskHelpers::Files.call(LOGGER)
    else
      VerifyTaskHelpers::SimFin.call(LOGGER)
      VerifyTaskHelpers::Logging.call(LOGGER)
      VerifyTaskHelpers::Database.call(LOGGER)
      VerifyTaskHelpers::Files.call(LOGGER)
    end
  end
end
