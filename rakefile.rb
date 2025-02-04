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
desc 'Builds the database from the current zip files'
task :default do
  console_logger = TTY::Logger.new
  console_logger.warn 'The default task has not been implemented yet.'

  log_process_ended
end

# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Verify Task
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
desc 'Confirms the environment is ready for operations'
task :verify, [:section, :root_task] do |_, args|
  LOGGER.info('-------------------- Executing Verify Command -------------------')

  args.with_defaults(section: :all)
  args.with_defaults(root_task: true)
  root_task = args[:root_task]

  verify_command = args[:section].to_sym
  Rake::Task['verify_tasks:all'].invoke(verify_command)

  LOGGER.info('-------------------- Verify Command Ended -----------------------')

  log_process_ended if root_task
end

# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Samples Task
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
desc 'Copies the SimFin sample files to the downloads folder'
task :samples, [:root_task] do |_, args|
  LOGGER.info('-------------------- Executing Samples Command ------------------')

  args.with_defaults(root_task: true)
  root_task = args[:root_task]

  Rake::Task['clean'].invoke(false)

  downloads_folder = Config::Folders.downloads
  files = FileList["#{Config::Folders.sample_files}/*.zip"]

  files.each do |file|
    FileUtils.cp(file, downloads_folder)
    LOGGER.debug("Copied #{file} to #{downloads_folder}")
  end

  LOGGER.info('-------------------- Samples Command Ended ----------------------')

  log_process_ended if root_task
end

# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Archive Task
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
desc 'Makes a backup copy of the SimFin files located in the downloads folder'
task :archive, [:root_task] do |_, args|
  LOGGER.info('-------------------- Executing Archive Command ------------------')

  args.with_defaults(root_task: true)
  root_task = args[:root_task]

  console_logger = TTY::Logger.new
  console_logger.warn 'The archive task has not been implemented yet.'

  LOGGER.info('-------------------- Archive Command Ended ----------------------')

  log_process_ended if root_task
end

# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Import Task
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
desc 'Imports the zip into the database'
task :import, [:root_task] do |_, args|
  LOGGER.info('-------------------- Executing Import Command -------------------')

  args.with_defaults(root_task: true)
  root_task = args[:root_task]

  console_logger = TTY::Logger.new
  console_logger.warn 'The samples task has not been implemented yet.'

  LOGGER.info('-------------------- Import Command Ended -----------------------')

  log_process_ended if root_task
end

# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Build Task
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
desc 'Builds the database from the imported zip files'
task :build, [:root_task] do |_, args|
  LOGGER.info('-------------------- Executing Build Command --------------------')

  args.with_defaults(root_task: true)
  root_task = args[:root_task]

  console_logger = TTY::Logger.new
  console_logger.warn 'The build task has not been implemented yet.'

  LOGGER.info('-------------------- Build Command Ended ------------------------')

  log_process_ended if root_task
end

# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Backup Task
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
desc 'Backups the database'
task :backup, [:root_task] do |_, args|
  LOGGER.info('-------------------- Executing Backup Command -------------------')

  args.with_defaults(root_task: true)
  root_task = args[:root_task]

  console_logger = TTY::Logger.new
  console_logger.warn 'The backup task has not been implemented yet.'

  LOGGER.info('-------------------- Backup Command Ended -----------------------')

  log_process_ended if root_task
end

# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Clear Task
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
desc 'Deletes the files in the temp and downloads folders'
task :clean, [:root_task] do |_, args|
  LOGGER.info('-------------------- Executing Clean Command --------------------')

  args.with_defaults(root_task: true)
  root_task = args[:root_task]

  files = FileList["#{Config::Folders.temp}/*.csv"]
  files.each do |file|
    FileUtils.rm(file)
    LOGGER.debug("Deleted #{file}")
  end

  files = FileList["#{Config::Folders.downloads}/*.zip"]
  files.each do |file|
    FileUtils.rm_f(file)
    LOGGER.debug("Deleted #{file}")
  end

  LOGGER.info('-------------------- Clean Command Ended ------------------------')

  log_process_ended if root_task
end
