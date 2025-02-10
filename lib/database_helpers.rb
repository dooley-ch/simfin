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

# This module handles the application's interaction with the database
module DatabaseHelpers
  class << self
    # Connects to the database and executes the SQL needed to import data into the given table.
    #
    # @param [string, _ToS] table_name - the name of the database table receiving the data
    # @param [string, _ToS] sql - the SQL to execute in order to import the data
    # @param [object] conn_info - the database credentials needed to connect to the database
    # @param [object, nil] logger - the application logger
    def import_table(table_name, sql, conn_info, logger = nil)
      conn = PG.connect dbname: conn_info.database, user: conn_info.user, password: conn_info.password

      conn.exec "truncate table staging.#{table_name} restart identity;"
      conn.exec sql
    rescue PG::Error => e
      logger&.error "Failed to import data to table #{table_name} - #{e.message}"
      raise
    ensure
      conn&.close
    end

    # Connects to the database and executes the given procedure
    #
    # @param [String] procedure_name
    # @param [object] conn_info - the database credentials needed to connect to the database
    # @param [object, nil] logger - the application logger
    def execute_stored_procedure(procedure_name, conn_info, logger = nil)
      conn = PG.connect dbname: conn_info.database, user: conn_info.user, password: conn_info.password
      sql = "call staging.#{procedure_name}();"

      conn.exec sql
    rescue PG::Error => e
      logger&.error "Failed to execute stored procedure #{procedure_name} - #{e.message}"
      raise
    ensure
      conn&.close
    end
  end
end
