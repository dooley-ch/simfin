# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     rakefile.rb
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
require 'logging'
require 'require_all'

require_all 'lib'

begin
  logging_config = Config::Logging.call

  log_file = Config::Files.log_file
  log_file_layout = Logging.layouts.pattern(pattern: '[%d] %-5l: %m\n', date_pattern: '%Y-%m-%d %H:%M:%S')
  LOGGER = Logging.logger['simfin_logger']
  LOGGER.level = logging_config.level.to_sym
  LOGGER.add_appenders Logging.appenders.rolling_file(log_file.to_s, age: 'daily', layout: log_file_layout)

  LOGGER.info('******************** Process Started ********************')
rescue StandardError => e
  console_logger = TTY::Logger.new
  console_logger.fatal('Unable to configure logging', e.message)

  abort
end

def log_process_ended
  LOGGER.info('******************** Process Ended ********************')
end

# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Default Task
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
task :default do
  console_logger = TTY::Logger.new
  console_logger.warn 'The default task has not been implemented yet.'

  log_process_ended
end

# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Verify Task
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
desc 'Confirms the environment is ready for operation'
task :verify do
  console_logger = TTY::Logger.new
  console_logger.warn 'The default task has not been implemented yet.'

  log_process_ended
end
