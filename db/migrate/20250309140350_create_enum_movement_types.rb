# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumMovementTypes < ActiveRecord::Migration[8.0]
  def change
    create_enum :movement_types, %i[
      restock purchase sale customer_return supplier_return transfer_in transfer_out
      adjustment correction reservation release_reservation initial_stock inspection
      quarantine release_from_quarantine
    ]
  end
end
