# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  self.implicit_order_column = "created_at"

  def touch_self(obj)
    obj.touch && self.touch
  end

  class << self
    def [](attribute)
      table[attribute]
    end

    def table
      arel_table
    end

    def without_order
      reorder(nil)
    end

    def none
      where(arel_table[:id].eq(nil).and(arel_table[:id].not_eq(nil)))
    end

    def scoped_table
      arel_table.alias(table_name)
    end

    def safe_find_or_create_by!(*args, &block)
      safe_find_or_create_by(*args, &block).tap do |record|
        raise ActiveRecord::RecordNotFound unless record.present?

        record.validate! unless record.persisted?
      end
    end

    def safe_find_or_create_by(*args, &block)
      record = find_by(*args)
      return record if record.present?

      transaction(requires_new: true) { all.create(*args, &block) }
    rescue ActiveRecord::RecordNotUnique
      find_by(*args)
    end
  end
end
