# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module containing set of shareable scopes and methods for ordering objects.
module Sortable
  extend ActiveSupport::Concern

  included do
    scope :order_id_asc, -> { reorder(arel_table[:id].asc) }
    scope :order_id_desc, -> { reorder(arel_table[:id].desc) }
    scope :order_created_asc, -> { reorder(arel_table[:created_at].asc) }
    scope :order_created_desc, -> { reorder(arel_table[:created_at].desc) }
    scope :order_updated_asc, -> { reorder(arel_table[:updated_at].asc) }
    scope :order_updated_desc, -> { reorder(arel_table[:updated_at].desc) }
  end

  class_methods do
    def order_by(method)
      simple_sorts.fetch(method, -> { all }).call
    end

    private

    def simple_sorts
      {
        id_asc: -> { order_id_asc },
        id_desc: -> { order_id_desc },
        created_asc: -> { order_created_asc },
        created_at_asc: -> { order_created_asc },
        created_desc: -> { order_created_desc },
        created_at_desc: -> { order_created_desc },
        updated_asc: -> { order_updated_asc },
        updated_at_asc: -> { order_updated_asc },
        updated_desc: -> { order_updated_desc },
        updated_at_desc: -> { order_updated_desc }
      }
    end
  end
end
