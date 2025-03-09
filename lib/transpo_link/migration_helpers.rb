# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# MigrationHelpers module provides utility methods for database migrations.
# These methods help streamline migration logic, making it more reusable and maintainable.
#
# Usage:
#   class SomeMigration < ActiveRecord::Migration[8.0]
#     include MigrationHelpers
#
#     def change
#       create_table :example_table do |t|
#         t.enum :category, enum_type: :example_enum
#         t.check_constraint "category IN #{enum_values('example_enum')}", name: "check_example_category_inclusion"
#       end
#     end
#   end
module TranspoLink
  module MigrationHelpers

    # Fetches all allowed values for a given PostgreSQL ENUM type and returns them
    # as a comma-separated string, formatted for use in SQL statements.
    #
    # @param enum_name [String, Symbol] The name of the PostgreSQL ENUM type.
    # @return [String] A comma-separated string of enum values, formatted for SQL.
    #
    # @example
    #   enum_values("business_categories") # => "'small', 'medium', 'large'"
    #
    def enum_values(enum_name)
      query = <<-SQL
        SELECT enumlabel
        FROM pg_enum
        JOIN pg_type ON pg_enum.enumtypid = pg_type.oid
        WHERE typname = '#{enum_name}'
      SQL

      ActiveRecord::Base.connection.execute(query).map do |row|
        "'#{row['enumlabel']}'"
      end.join(", ")
    end
  end
end
