# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module MigrationHelpers
  def connection
    ActiveRecord::Base.connection
  end

  # Checks if a table exists
  def table_exists?(table_name)
    connection.table_exists?(table_name)
  end

  # Returns column objects for a given table
  def table_columns(table_name)
    connection.columns(table_name)
  end

  # Returns index objects for a given table
  def table_indexes(table_name)
    connection.indexes(table_name)
  end

  # Returns check constraint objects for a given table
  def table_constraints(table_name)
    connection.check_constraints(table_name)
  end

  # Returns foreign key objects for a given table
  def table_foreign_keys(table_name)
    connection.foreign_keys(table_name)
  end

  # Returns primary key column name for a given table
  def primary_key(table_name)
    connection.primary_key(table_name)
  end

  # Returns a hash of column definitions indexed by column name
  def column_definitions(table_name)
    table_columns(table_name).index_by(&:name)
  end

  # Returns a hash of index definitions indexed by index name
  def index_definitions(table_name)
    table_indexes(table_name).index_by(&:name)
  end

  # Returns a hash of check constraint definitions indexed by constraint name
  def constraint_definitions(table_name)
    table_constraints(table_name).index_by(&:name)
  end

  # Returns a hash of foreign key definitions indexed by column name
  def foreign_key_definitions(table_name)
    table_foreign_keys(table_name).index_by(&:column)
  end

  # Returns an array of column names
  def column_names(table_name)
    table_columns(table_name).map(&:name)
  end

  # Returns an array of index names
  def index_names(table_name)
    table_indexes(table_name).map(&:name)
  end

  # Returns an array of check constraint names
  def constraint_names(table_name)
    table_constraints(table_name).map(&:name)
  end

  # Returns an array of foreign key column names
  def foreign_key_columns(table_name)
    table_foreign_keys(table_name).map(&:column)
  end

  # Returns default values for columns as a hash
  def column_defaults(table_name)
    table_columns(table_name).each_with_object({}) do |col, hash|
      hash[col.name] = col.default
    end
  end
end
