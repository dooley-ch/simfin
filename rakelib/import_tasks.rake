# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     import_tasks.rb
# ╠═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Created: 05.02.2025
# ║
# ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
# ║
# ║     History:
# ║     05.02.2025: Initial version
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
# frozen_string_literal: true

require 'zip'
require 'tty-spinner'

# rubocop : disable Metrics/BlockLength
namespace :import_tasks do
  task all: %i[unzip_files import_other_files]

  task :unzip_files do # rubocop : disable Rake/Desc
    spinner = TTY::Spinner.new('[:spinner] Unzipping files ...', format: :shark)
    spinner.auto_spin

    temp_folder = Config::Folders.temp
    zip_files = FileList.new("#{Config::Folders.downloads}/*.zip")

    unzipped_files = 0
    zip_files.each do |zip_file|
      Zip::File.open(zip_file) do |file|
        file.each do |csv_file|
          unziped_file = Pathname.new(temp_folder).join(csv_file.name)
          FileUtils.rm_rf(unziped_file)

          csv_file.extract(unziped_file.to_s)

          unzipped_files += 1
          LOGGER.debug("File unzipped: #{unziped_file}")
        end
      end
    end

    LOGGER.info("Total unzipped files: #{unzipped_files}")

    spinner.stop('Done')
  end

  task :import_other_files do # rubocop : disable Rake/Desc
    file_names = SimFinNameBuilder.others(:csv, LOGGER)
    temp_folder = Config::Folders.temp
    db_info = Config::Database.call(LOGGER)

    # Import markets table
    file = file_names[:markets]

    query = %{
      COPY staging.markets (market_id, market_name, currency)  FROM '#{temp_folder}/#{file}'
      DELIMITER ';' HEADER csv;
    }

    DatabaseHelpers.import_table('markets', query, db_info, LOGGER)
    LOGGER.info('Markets file imported')

    # Import industries table
    file = file_names[:industries]

    query = %{
      COPY staging.industries (industry_id, industry, sector)  FROM '#{temp_folder}/#{file}'
      DELIMITER ';' HEADER csv;
    }

    DatabaseHelpers.import_table('industries', query, db_info, LOGGER)
    LOGGER.info('Industries file imported')
  end
end
# rubocop : enable Metrics/BlockLength
