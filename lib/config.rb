# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     config.rb
# ╠═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Created: 03.02.2025
# ║
# ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
# ║
# ║     History:
# ║     03.02.2025: Initial version
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
# frozen_string_literal: true

require 'pathname'
require 'fileutils'
require 'errors'
require 'yaml'

module Config
  LoggingInfo = Struct.new(:level, :file)
  DatabaseInfo = Struct.new(:database, :user, :password)
  SimFinInfo = Struct.new(:regions, :time_frames, :companies, :others)

  module SimFin
    class << self
      def call(logger = nil)
        values = ConfigFile.load_hash('simfin', logger)
        logger&.debug 'Database information loaded...'
        SimFinInfo.new(values['regions'], values['time-frames'], values['companies'], values['others'])
      end
    end
  end

  module Database
    class << self
      def call(logger = nil)
        values = ConfigFile.load_hash('database', logger)
        logger&.debug 'Database information loaded...'
        DatabaseInfo.new(values['database'], values['user'], values['password'])
      end
    end
  end

  module Logging
    class << self
      def call(logger = nil)
        values = ConfigFile.load_hash('logging', logger)
        logger&.debug 'Logging information loaded...'
        LoggingInfo.new(values['level'], values['file_name'])
      end
    end
  end

  module ConfigFile
    class << self
      def load_hash(hash_name, logger = nil)
        config_file = Files.config_file.to_s
        unless File.exist?(config_file)
          logger&.error "Config file #{config_file} not found"
          raise Errors::FileNotFoundError, config_file
        end

        begin
          contents = YAML.load_file config_file
        rescue Psych::SyntaxError => e
          error_message = "YAML syntax error in config file': #{e.message}"
          logger&.error error_message
          raise Errors::ConfigurationError, error_message
        end

        if contents.key?(hash_name)
          logger&.debug "Config hash: #{hash_name} loaded successfully"
          return contents[hash_name]
        end

        error_message = "Config hash: #{hash_name} not found in config file"
        logger&.error error_message
        raise Errors::ConfigurationError, error_message
      end
    end
  end

  module Folders
    class << self
      def logs
        folder = Pathname.new(base_folder).join('logs').expand_path
        FileUtils.mkdir_p(folder.to_s)
        folder.to_s
      end

      def downloads
        folder = Pathname.new(base_folder).join('downloads').expand_path
        FileUtils.mkdir_p(folder.to_s)
        folder.to_s
      end

      def temp
        folder = Pathname.new(base_folder).join('temp').expand_path
        FileUtils.mkdir_p(folder.to_s)
        folder.to_s
      end

      def archive
        folder = Pathname.new(base_folder).join('archive').expand_path
        FileUtils.mkdir_p(folder.to_s)
        folder.to_s
      end

      private

      def base_folder
        folder = Pathname.new(__FILE__).dirname.dirname.join('data').expand_path
        FileUtils.mkdir_p(folder.to_s)
        folder.to_s
      end
    end
  end

  module Files
    class << self
      def log_file
        values = Logging.call
        Pathname.new(Folders.logs).expand_path.join(values.file)
      end

      def config_file
        Pathname.new(__FILE__).dirname.dirname.expand_path.join('config.yml')
      end
    end
  end
end
