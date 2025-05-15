# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AccessControl::Action < ApplicationRecord
  has_many :permissions,
           class_name: "AccessControl::Permission",
           inverse_of: :action,
           dependent: :restrict_with_exception
end
