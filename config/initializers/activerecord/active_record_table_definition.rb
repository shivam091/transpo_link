# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Be sure to restart your server when you modify this file.

module ActiveRecord
  module ConnectionAdapters
    class TableDefinition
      # Appends columns `created_at` and `updated_at` to a table.
      #
      # It is used in table creation like:
      # create_table :users do |t|
      #   t.timestamps_with_timezone
      # end
      def timestamps_with_timezone(**options)
        [:created_at, :updated_at].each do |column_name|
          datetime_with_timezone(column_name, **options)
        end
      end

      # Adds specified column with appropriate timestamp type
      #
      # It is used in table creation like:
      # create_table 'users' do |t|
      #   t.datetime_with_timezone :last_activity_at
      # end
      def datetime_with_timezone(column_name, **options)
        column(column_name, :timestamptz, **options)
      end
    end
  end
end
