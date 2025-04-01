# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateInventoryMovements < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    create_table :inventory_movements, id: :uuid do |t|
      t.references :inventory,
                   type: :uuid,
                   foreign_key: {
                     to_table: :inventories,
                     name: :fk_inventory_movements_inventory_id_on_inventories,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.decimal :quantity, precision: 12, scale: 2, default: 0.0 # +ve for incoming, -ve for outgoing
      t.enum :movement_type, enum_type: :movement_types
      t.string :inventory_unit # Ensures correct unit tracking
      t.decimal :unit_cost, precision: 12, scale: 2 # Cost per unit at the time of movement
      t.decimal :total_cost, precision: 12, scale: 2 # Total cost of the movement
      t.string :currency
      t.timestamptz :movement_date, default: -> { "CURRENT_TIMESTAMP" }
      t.references :source,
                   type: :uuid,
                   polymorphic: true,
                   null: false,
                   index: {using: :btree}
      t.jsonb :metadata, default: "{}", index: {using: :gin} # Store additional data if needed
      t.timestamps_with_timezone null: false

      t.index [:inventory_id, :source_id, :source_type, :movement_type], using: :btree

      t.check_constraint "quantity IS NOT NULL", name: :check_inventory_movements_quantity_presence
      t.check_constraint "quantity != 0.0", name: :check_inventory_movements_quantity_nonzero

      t.check_constraint "movement_type IS NOT NULL", name: :check_inventory_movements_movement_type_presence
      t.check_constraint "movement_type IN (#{enum_values('movement_types')})", name: :check_inventory_movements_movement_type_inclusion

      t.check_constraint "inventory_unit IS NOT NULL AND inventory_unit  <> ''", name: :check_inventory_movements_inventory_unit_presence

      t.check_constraint "unit_cost IS NOT NULL", name: :check_inventory_movements_unit_cost_presence
      t.check_constraint "unit_cost >= 0.0", name: :check_inventory_movements_unit_cost_non_negative

      t.check_constraint "total_cost IS NOT NULL", name: :check_inventory_movements_total_cost_presence
      t.check_constraint "total_cost >= unit_cost", name: :check_inventory_movements_total_cost_numericality

      t.check_constraint "currency IS NOT NULL AND currency  <> ''", name: :check_inventory_movements_currency_presence
    end
  end
end
