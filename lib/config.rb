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

module Config
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
        Pathname.new(Folders.logs).expand_path.join('simfin.log')
      end

      def config_file
        Pathname.new(__FILE__).dirname.dirname.expand_path.join('config.yml')
      end
    end
  end
end
