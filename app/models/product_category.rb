# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ProductCategory < ApplicationRecord
  include Sortable, Toggleable, Pageable

  LISTING_ATTRIBUTES = %i[name parent_category_id products_count].freeze

  attribute :is_active, default: false

  validates :name,
            presence: true,
            length: {in: 2..255},
            uniqueness: {scope: :parent_category_id, case_sensitive: false},
            reduce: true

  has_many :sub_categories,
           class_name: "ProductCategory",
           foreign_key: :parent_category_id,
           inverse_of: :parent_category,
           dependent: :destroy
  has_many :products, inverse_of: :product_category, dependent: :restrict_with_exception

  belongs_to :parent_category, class_name: "ProductCategory", optional: true, inverse_of: :sub_categories

  delegate :name, to: :parent_category, prefix: true, allow_nil: true

  default_scope -> { order_created_desc }

  class << self
    def select_options
      active.pluck(:name, :id)
    end
  end
end
