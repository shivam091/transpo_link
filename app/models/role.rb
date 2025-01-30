# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Role < ApplicationRecord
  include Toggleable

  attribute :is_active, default: false

  validates :name,
            presence: true,
            uniqueness: true,
            length: {in: 2..55},
            reduce: true

  has_many :users, dependent: :restrict_with_exception
end
