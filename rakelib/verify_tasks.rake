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
  task :all, [:section] do |_, args| # rubocop : disable Rake/Desc
    verify_type = args[:section].to_sym

    case verify_type
    when :simfin
      VerifyTaskHelpers::SimFin.call(LOGGER)
    when :logging
      VerifyTaskHelpers::Logging.call(LOGGER)
    when :database
      VerifyTaskHelpers::Database.call(LOGGER)
    else
      result = VerifyTaskHelpers::SimFin.call(LOGGER)
      result = result and VerifyTaskHelpers::Logging.call(LOGGER) # rubocop : disable Lint/SelfAssignment
      result = result and VerifyTaskHelpers::Database.call(LOGGER) # rubocop : disable Lint/SelfAssignment

      if result
        puts 'All good'
      else
        puts 'All bad'
      end
    end
  end
end
