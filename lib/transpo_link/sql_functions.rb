# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TranspoLink
  module SqlFunctions
    extend self

    def lower(value, column_alias = nil)
      value = quoted(value)
      if column_alias
        aliased_sql_function("LOWER", [value], column_alias)
      else
        sql_function("LOWER", [value])
      end
    end

    def avg(value, column_alias = nil)
      if column_alias
        aliased_sql_function("AVG", [value], column_alias)
      else
        sql_function("AVG", [value])
      end
    end

    private

    def aliased_sql_function(name, args, column_alias)
      alias_as_column(sql_function(name, args), column_alias)
    end

    def sql_function(name, args)
      Arel::Nodes::NamedFunction.new(name, args)
    end

    def alias_as_column(value, alias_to)
      Arel::Nodes::As.new(value, Arel::Nodes::SqlLiteral.new(alias_to))
    end

    def quoted(value)
      Arel::Nodes.build_quoted(value)
    end
  end
end
