# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateInventoryRestocks < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_restocks, id: :uuid do |t|
      t.references :inventory_batch,
                   type: :uuid,
                   foreign_key: {
                     to_table: :inventory_batches,
                     name: :fk_inventory_restocks_inventory_batch_id_on_inventory_batches,
                     on_delete: :cascade
                   },
                   null: false,
                   index: {using: :btree}
      t.text :comment
      t.text :note
      t.timestamps_with_timezone null: false

      t.check_constraint "comment IS NOT NULL AND comment <> ''", name: :check_inventory_restocks_comment_presence
      t.check_constraint "CHAR_LENGTH(comment) <= 1000 AND CHAR_LENGTH(comment) > 0", name: :check_inventory_restocks_comment_length

      t.check_constraint "CHAR_LENGTH(note) <= 1000", name: :check_purchase_orders_note_length
    end
  end
end
