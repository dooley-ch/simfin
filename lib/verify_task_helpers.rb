# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     verify_task_helpers.rb
# ╠═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Created: 03.02.2025
# ║
# ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
# ║
# ║     History:
# ║     03.02.2025: Initial version
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
# frozen_string_literal: true

require 'pastel'

module VerifyTaskHelpers
  module ReportHelpers
    # noinspection RubyResolve
    def report_errors(section_name, errors)
      pastel = Pastel.new
      puts pastel.red.on_black.bold("\nThe #{section_name} configuration has errors:\n")
      errors.each do |error|
        puts pastel.blue.on_black.bold(" - #{error}")
      end
    end

    # noinspection RubyResolve
    def report_success(section_name)
      pastel = Pastel.new
      puts pastel.green.on_black.bold("\nThe #{section_name} configuration is valid\n")
    end
  end

  module SimFin
    class << self
      include ReportHelpers

      # rubocop : disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength
      def call(logger = nil)
        logger&.debug 'SimFin check executed'

        errors = []

        begin
          values = Config::ConfigFile.load_hash('simfin')
        rescue Errors::ConfigurationError
          errors << 'Entire simfin section missing from config file'
          report_errors('SimFin', errors)
          return false
        end

        errors << 'Regions definition section missing' unless values.key?('regions')
        errors << 'Time frames definition section missing' unless values.key?('time-frames')
        errors << 'Companies definition section missing' unless values.key?('companies')
        errors << 'Others definition section missing' unless values.key?('others')

        # Check the contents of the regions definition
        if values.key?('regions')
          region_values = values['regions']

          errors << 'Regions definition is not a list' unless region_values.is_a?(Array)
          errors << 'Regions definition is empty' if region_values.empty?
        end

        # Check the contents of the time-frames definition
        if values.key?('time-frames')
          time_frame_values = values['time-frames']

          errors << 'Time Frames definition is not a list' unless time_frame_values.is_a?(Array)
          errors << 'Time Frames definition is empty' if time_frame_values.empty?
        end

        # Check the contents of the companies definition
        if values.key?('companies')
          companies_values = values['companies']

          errors << 'Companies definition is not a list' unless companies_values.is_a?(Array)
          errors << 'Companies definition is empty' if companies_values.empty?
        end

        # Check the contents of the others definition
        if values.key?('others')
          others_values = values['others']

          errors << 'Others definition is not a list' unless others_values.is_a?(Array)
          errors << 'Others definition is empty' if others_values.empty?
        end

        if errors.empty?
          report_success('SimFin')
          logger&.debug 'SimFin check OK'
          return true
        end

        report_errors('SimFin', errors)
        logger&.debug 'SimFin check failed!'
        false
      end
      # rubocop : enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength
    end
  end

  module Logging
    class << self
      include ReportHelpers

      # rubocop : disable Metrics/MethodLength
      def call(logger = nil)
        logger&.debug 'Logging check executed'

        errors = []

        begin
          values = Config::ConfigFile.load_hash('logging')
        rescue Errors::ConfigurationError
          errors << 'Entire logging section missing from config file'
          report_errors('Logging', errors)
          return false
        end

        errors << 'File name not defined' unless values.key?('file_name')
        errors << 'Log level not defined' unless values.key?('level')

        if errors.empty?
          report_success('Logging')
          logger&.debug 'Logging check OK'
          return true
        end

        report_errors('Logging', errors)
        logger&.debug 'Logging check failed!'
        false
      end
      # rubocop : enable Metrics/MethodLength
    end
  end

  module Database
    class << self
      include ReportHelpers

      # rubocop : disable Metrics/MethodLength
      def call(logger = nil)
        logger&.debug 'Database check executed'

        errors = []

        begin
          values = Config::ConfigFile.load_hash('database')
        rescue Errors::ConfigurationError
          errors << 'Entire database section missing from config file'
          report_errors('Database', errors)
          return false
        end

        errors << 'Database name not defined' unless values.key?('database')
        errors << 'User name not defined' unless values.key?('user')
        errors << 'User password not defined' unless values.key?('password')

        if errors.empty?
          report_success('Database')
          logger&.debug 'Database check OK'
          return true
        end

        report_errors('Database', errors)
        logger&.debug 'Database check failed!'
        false
      end
      # rubocop : enable Metrics/MethodLength
    end
  end
end
