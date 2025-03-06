# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductCategory < ApplicationRecord
  include Sortable

  attribute :is_active, default: false

  has_many :sub_categories, class_name: "ProductCategory", foreign_key: :parent_category_id, dependent: :destroy

  belongs_to :parent_category, class_name: "ProductCategory", optional: true, inverse_of: :sub_categories

  delegate :name, to: :parent_category, prefix: true, allow_nil: true

  default_scope -> { order_created_desc }
end
