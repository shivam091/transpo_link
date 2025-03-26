# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AddTrackingMethodInInventories < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    add_column :inventories, :tracking_method, :enum, enum_type: :tracking_methods

    add_check_constraint :inventories, "tracking_method IS NOT NULL", name: :check_inventories_tracking_method_presence
    add_check_constraint :inventories, "tracking_method IN (#{enum_values('tracking_methods')})", name: :check_inventories_tracking_method_inclusion
  end
end
