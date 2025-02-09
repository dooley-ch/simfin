# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     sim_file_name_builder.rb
# ╠═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Created: 03.02.2025
# ║
# ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
# ║
# ║     History:
# ║     03.02.2025: Initial version
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
# frozen_string_literal: true

require_relative 'config'

# This module dynamically builds the SimFin file names according to their naming convention
module SimFinNameBuilder
  # noinspection RubyClassVariableUsageInspection
  class << self
    # Returns the region names as defined in the config file in the SimFin section
    #
    # @param [logger, nil] logger - An instance of the application logger
    # @return [Array]
    def regions(logger = nil)
      load_config logger

      names = []

      names.push(*@@simfin_info.regions.map { |region| region })

      names
    end

    # Returns a list of time frames as defined in the config file in the SimFin section
    #
    # @param [logger, nil] logger - An instance of the application logger
    # @return [Array]
    def time_frames(logger = nil)
      load_config logger

      names = []

      names.push(*@@simfin_info.time_frames.map { |time| time })

      names
    end

    # Returns the names of the other master files used by SimFin - markets, sectors and industries
    #
    # @param [Symbol] extension - The file extension to assign to the generated file names
    # @param [logger, nil] logger - An instance of the application logger
    # @return [Hash]
    def others(extension = :zip, logger = nil)
      load_config logger
      values = {}

      @@simfin_info.others.each do |file|
        values[file.to_sym] = "#{file}.#{extension}"
      end

      values
    end

    # This method returns a list of the SimFin company file names
    #
    # @param [Symbol] extension - The file extension to assign to the generated file names
    # @param [logger, nil] logger - An instance of the application logger
    # @return [Hash]
    def companies(extension = :zip, logger = nil)
      load_config logger
      values = {}

      @@simfin_info.regions.each do |region|
        values[region.to_sym] = "#{region}-companies.#{extension}"
      end

      values
    end

    # This method returns a list of the SimFin share price file names
    #
    # @param [Symbol] extension - The file extension to assign to the generated file names
    # @param [logger, nil] logger - An instance of the application logger
    # @return [Hash]
    def share_prices(extension = :zip, logger = nil)
      load_config logger
      values = {}

      @@simfin_info.regions.each do |region|
        values[region.to_sym] = "#{region}-shareprices-daily.#{extension}"
      end

      values
    end

    # This method returns a list of all the SimFin file names
    #
    # @param [Symbol] extension - The file extension to assign to the generated file names
    # @param [logger, nil] logger - An instance of the application logger
    # @return [Array]
    # rubocop : disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize
    def all(extension = :zip, logger = nil)
      load_config logger

      files = []

      # Add the markets and industries files
      files.push(*@@simfin_info.others.map { |file| "#{file}.#{extension}" })

      # Add the companies files
      files.push(*@@simfin_info.regions.map { |region| "#{region}-companies.#{extension}" })

      # Add the share prices files
      files.push(*@@simfin_info.regions.map { |region| "#{region}-shareprices-daily.#{extension}" })

      # Add financial statements
      # rubocop : disable Style/CombinableLoops
      @@simfin_info.regions.each do |region|
        @@simfin_info.companies.each do |company_type|
          # Income Statements
          @@simfin_info.time_frames.each do |time_frame|
            if company_type == 'standard'
              files.push("#{region}-income-#{time_frame}.#{extension}")
            else
              files.push("#{region}-income-#{company_type}-#{time_frame}.#{extension}")
            end
          end

          # Cash Flow Statements
          @@simfin_info.time_frames.each do |time_frame|
            if company_type == 'standard'
              files.push("#{region}-cashflow-#{time_frame}.#{extension}")
            else
              files.push("#{region}-cashflow-#{company_type}-#{time_frame}.#{extension}")
            end
          end

          # Balance Sheets
          @@simfin_info.time_frames.each do |time_frame|
            if company_type == 'standard'
              files.push("#{region}-balance-#{time_frame}.#{extension}")
            else
              files.push("#{region}-balance-#{company_type}-#{time_frame}.#{extension}")
            end
          end
        end
      end
      # rubocop : enable Style/CombinableLoops

      files
    end
    # rubocop : enable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/AbcSize

    private

    def load_config(logger = nil)
      @@simfin_info ||= Config::SimFin.call(logger) # rubocop : disable Style/ClassVars
    end
  end
end
