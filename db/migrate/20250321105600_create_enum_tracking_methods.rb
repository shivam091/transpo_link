# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumTrackingMethods < ActiveRecord::Migration[8.0]
  def change
    create_enum :tracking_methods, %i[fifo lifo average_cost]
  end
end
