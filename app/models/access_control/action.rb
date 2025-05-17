# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AccessControl::Action < ApplicationRecord
  normalizes :label_key, with: ->(label_key) { label_key.strip.downcase }

  validates :label_key,
            presence: true,
            length: {maximum: 55},
            uniqueness: true,
            reduce: true

  has_many :permissions,
           class_name: "AccessControl::Permission",
           inverse_of: :action,
           dependent: :restrict_with_exception
end
