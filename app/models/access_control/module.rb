# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AccessControl::Module < ApplicationRecord
  validates :label_key,
            presence: true,
            length: {maximum: 55},
            uniqueness: true,
            reduce: true

  has_many :permissions,
           class_name: "AccessControl::Permission",
           inverse_of: :module,
           dependent: :restrict_with_exception
end
