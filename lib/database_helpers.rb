# ╔═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     database_helpers.rb
# ╠═════════════════════════════════════════════════════════════════════════════════════════════════
# ║     Created: 06.02.2025
# ║
# ║     Copyright (c) 2025 James Dooley <james@dooley.ch>
# ║
# ║     History:
# ║     06.02.2025: Initial version
# ╚═════════════════════════════════════════════════════════════════════════════════════════════════
# frozen_string_literal: true

require 'pg'

module DatabaseHelpers
  class << self
    def import_table(table_name, sql, conn_info, logger = nil)
      begin # rubocop : disable Style/RedundantBegin
        conn = PG.connect dbname: conn_info.database, user: conn_info.user, password: conn_info.password

        conn.exec "truncate table staging.#{table_name} restart identity;"
        conn.exec sql
      rescue PG::Error => e
        logger&.error "Failed to import data to table #{table_name} - #{e.message}"
        raise
      ensure
        conn&.close
      end
    end
  end
end
