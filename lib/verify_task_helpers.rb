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
require 'tty-table'
require_relative 'sim_fin_name_builder'
require_relative 'config'

# This module contains a number of methods used by the verification task to ensure the system is
# configured correctly and has the data needed to build the SimFin database
module VerifyTaskHelpers
  # This module provides helper functions used by other modules in this suite
  # to report errors to the user
  module ReportHelpers
    # This method display the error list for a configuration section when verified
    #
    # @param [String] section_name - The name of the section containing the errors
    # @param [Array] errors - The list of errors in the validated section
    #
    # noinspection RubyResolve
    def report_errors(section_name, errors)
      pastel = Pastel.new
      puts pastel.red.bold("\nThe #{section_name} configuration has errors:\n")
      errors.each do |error|
        puts pastel.blue.on_black.bold(" - #{error}")
      end
    end

    # This method reports the successful validation of a configuration section
    #
    # @param [String] section_name
    #
    # noinspection RubyResolve
    def report_success(section_name)
      pastel = Pastel.new
      puts pastel.green.bold("\nThe #{section_name} configuration is valid\n")
    end
  end

  # This module checks to ensure that all the SimFin data files are available for processing
  module Files
    class << self
      include ReportHelpers

      # Executes the validation process to check the existence of the downloaded SimFin data files
      #
      # @param [logger, nil] logger - an instance of the application logger
      # @param [Boolean] - indicates if the outcome should be reported on the screen
      #
      # rubocop : disable Metrics/AbcSize, Metrics/CyclomaticComplexity,
      # Lint/RedundantCopDisableDirective
      # noinspection RubyControlFlowConversionInspection
      def call(logger = nil, report_outcome: true)
        logger&.debug 'SimFin check executed'

        missing_files = []

        required_files = SimFinNameBuilder.all
        downloads_folder_contents = FileList["#{Config::Folders.downloads}/*.zip"].map do |file_name|
          File.basename(file_name)
        end.to_ary

        required_files.each do |file|
          missing_files << file unless downloads_folder_contents.include?(file)
        end

        if missing_files.empty?
          report_success('Import Files') if report_outcome
          logger&.debug 'Files check OK'
          return true
        end

        report_errors(missing_files) if report_outcome
        logger&.debug 'Files check failed!'
        false
      end
      # rubocop : enable Metrics/AbcSize, Metrics/CyclomaticComplexity

      private

      # This method maps a regional key from a file name to it's description
      #
      # @param [String] file_name
      # @return [String]
      def region_name(file_name)
        region = file_name[0..1]
        # noinspection RubyControlFlowConversionInspection
        case region
        when 'de'
          'German'
        when 'cn'
          'China'
        else
          'USA'
        end
      end

      # This method maps a statement key from a file name to it's description
      #
      # @param [String] file_name
      # @return [String]
      # noinspection RubyControlFlowConversionInspection
      def statement_type(file_name)
        if file_name.include?('balance-')
          'Balance Sheet'
        elsif file_name.include?('cashflow-')
          'Cash Flow Statement'
        elsif file_name.include?('income-')
          'Income Statement'
        else
          'Unknown Document'
        end
      end

      # This method maps a company type key from a file name to it's description
      #
      # @param [String] file_name
      # @return [String]
      def company_type(file_name)
        if file_name.include?('bank-')
          'Bank'
        elsif file_name.include?('insurance-')
          'Insurance'
        else
          ''
        end
      end

      # This method maps a time key from a file name to it's description
      #
      # @param [String] file_name
      # @return [String]
      def time_frame(file_name)
        if file_name.include?('-annual')
          'Annual'
        elsif file_name.include?('-quarterly')
          'Quarterly'
        elsif file_name.include?('-ttm')
          'TTM'
        else
          'Unknown Time Frame'
        end
      end

      # This method displays the list of missing files to the user
      #
      # @param [Array] missing_files - list of missing files
      #
      # rubocop : disable Metrics/AbcSize
      def report_errors(missing_files)
        pastel = Pastel.new
        blue = pastel.blue.bold.detach
        yellow = pastel.yellow.bold.detach

        puts pastel.red.bold("\nThe following file(s) are missing from the downloads folder:\n")

        header = [blue.call('  File Name  '), blue.call('  Statement Type  '), blue.call('  Region  '),
                  blue.call('  Company Type  '), blue.call('  Time Frame  ')]
        table = TTY::Table.new(header: header)

        missing_files.sort!
        missing_files.each do |file|
          table << [yellow.call("  #{file}  "), yellow.call("  #{statement_type(file)}  "),
                    yellow.call("  #{region_name(file)}  "), yellow.call("  #{company_type(file)}  "),
                    yellow.call("  #{time_frame(file)}  ")]
        end

        puts table.render(:ascii, indent: 2)
      end
      # rubocop : enable Metrics/AbcSize
    end
  end

  # This module validates the SimFin information stored in the config file
  module SimFin
    class << self
      include ReportHelpers

      # Executes the validation process to check the SimFin configuration data
      #
      # @param [logger, nil] logger - an instance of the application logger
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

  # This module validates the logging confirmation information stored in the config file
  module Logging
    class << self
      include ReportHelpers

      # Executes the validation process to check the existence of the logging configuration
      #
      # @param [logger, nil] logger - an instance of the application logger
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
    end
  end

  # This module is used to validate the database connection information stored in the config file
  module Database
    class << self
      include ReportHelpers

      # Executes the validation process to check the existence of the database configuration
      #
      # @param [logger, nil] logger - an instance of the application logger
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
    end
  end
end
