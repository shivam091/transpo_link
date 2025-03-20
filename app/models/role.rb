# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Role < ApplicationRecord
  include Toggleable

  validates :name,
            presence: true,
            length: {in: 2..55},
            uniqueness: true,
            reduce: true

  has_many :users, inverse_of: :role, dependent: :restrict_with_exception
end
