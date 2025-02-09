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
require_relative 'errors'
require 'yaml'

module Config
  # This structure holds the logging configuration information
  LoggingInfo = Struct.new(:level, :file)

  # This structure holds the database connection credentials
  DatabaseInfo = Struct.new(:database, :user, :password)

  # This structure holds the SimFin configuration information
  SimFinInfo = Struct.new(:regions, :time_frames, :companies, :others)

  # This module handles the loading of the SimFin configuration information
  module SimFin
    class << self
      # Loads the SimFin configuration information
      #
      # @param [logger, nil] logger - An instance of the application logger
      # @return [SimFinInfo]
      def call(logger = nil)
        values = ConfigFile.load_hash('simfin', logger)
        logger&.debug 'SimFin information loaded...'
        SimFinInfo.new(values['regions'], values['time-frames'], values['companies'], values['others'])
      end
    end
  end

  # This module handles the loading of the database connection information
  module Database
    class << self
      # Loads the database connection configuration information
      #
      # @param [logger, nil] logger - An instance of the application logger
      # @return [DatabaseInfo]
      def call(logger = nil)
        values = ConfigFile.load_hash('database', logger)
        logger&.debug 'Database information loaded...'
        DatabaseInfo.new(values['database'], values['user'], values['password'])
      end
    end
  end

  # This module handles the loading of the logging configuration information
  module Logging
    class << self
      # Loads the logging configuration information
      #
      # @param [logger, nil] logger - An instance of the application logger
      # @return [LoggingInfo]
      def call(logger = nil)
        values = ConfigFile.load_hash('logging', logger)
        logger&.debug 'Logging information loaded...'
        LoggingInfo.new(values['level'], values['file_name'])
      end
    end
  end

  # This module handles the reading and parsing of the config file
  module ConfigFile
    class << self
      # @param [String] hash_name - The name of the required YAML hash
      # @param [logger, nil] logger - An instance of the application logger
      # @return [Hash]
      def load_hash(hash_name, logger = nil)
        contents = load_file_contents logger

        if contents.key?(hash_name)
          logger&.debug "Config hash: #{hash_name} loaded successfully"
          return contents[hash_name]
        end

        error_message = "Config hash: #{hash_name} not found in config file"
        logger&.error error_message
        raise Errors::ConfigurationError, error_message
      end

      private

      # This method reads the contents of the config file and parses it into a YAML object
      #
      # @param [logger, nil] logger - An instance of the application logger
      def load_file_contents(logger = nil)
        config_file = Files.config_file.to_s
        unless File.exist?(config_file)
          logger&.error "Config file #{config_file} not found"
          raise Errors::FileNotFoundError, config_file
        end

        begin
          YAML.load_file config_file
        rescue Psych::SyntaxError => e
          error_message = "YAML syntax error in config file': #{e.message}"
          logger&.error error_message
          raise Errors::ConfigurationError, error_message
        end
      end
    end
  end

  # This module returns the names and locations of the various folders used by
  # the application
  module Folders
    class << self
      # Returns the name of the folder used to store log files
      #
      # @return [String]
      def logs
        folder = Pathname.new(base_data_folder).join('logs').expand_path
        FileUtils.mkdir_p(folder.to_s)
        folder.to_s
      end

      # Returns the name of the folder containing the downloaded SimFin files
      #
      # @return [String]
      def downloads
        folder = Pathname.new(base_data_folder).join('downloads').expand_path
        FileUtils.mkdir_p(folder.to_s)
        folder.to_s
      end

      # Returns the name of the temp folder to be used by the application
      #
      # @return [String]
      def temp
        folder = Pathname.new(base_data_folder).join('temp').expand_path
        FileUtils.mkdir_p(folder.to_s)
        folder.to_s
      end

      # Returns the name of the folder to use in archiving the downloaded files
      #
      # @return [String]
      def archive
        folder = Pathname.new(base_data_folder).join('archive').expand_path
        FileUtils.mkdir_p(folder.to_s)
        folder.to_s
      end

      # Returns the name of the folder containing the sample data files
      #
      # @return [String]
      def sample_files
        Pathname.new(root_folder).join('sample-files').expand_path.to_s
      end

      private

      def base_data_folder
        folder = Pathname.new(root_folder).join('data').expand_path
        FileUtils.mkdir_p(folder.to_s)
        folder.to_s
      end

      def root_folder
        Pathname.new(__FILE__).dirname.dirname.expand_path.to_s
      end
    end
  end

  # This module returns the names of various files used by the application
  module Files
    class << self
      # Returns the fully qualified name of the log file
      #
      # @return [Pathname]
      def log_file
        values = Logging.call
        Pathname.new(Folders.logs).expand_path.join(values.file)
      end

      # Returns the fully qualified name of the config file
      #
      # @return [Pathname]
      def config_file
        Pathname.new(__FILE__).dirname.dirname.expand_path.join('config.yml')
      end
    end
  end
end
