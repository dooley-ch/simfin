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

namespace :import_tasks do
  task all: %i[unzip_files import_files]

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

  task :import_files do # rubocop : disable Rake/Desc
    puts 'import files'
  end
end
