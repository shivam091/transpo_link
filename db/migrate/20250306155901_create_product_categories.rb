# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateProductCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :product_categories, id: :uuid do |t|
      t.string :name
      t.integer :products_count, default: 0
      t.references :parent_category,
                   type: :uuid,
                   foreign_key: {
                     to_table: :product_categories,
                     name: :fk_product_categories_parent_category_id_on_product_categories,
                     on_delete: :cascade
                   },
                   null: true,
                   index: {using: :btree}
      t.boolean :is_active, default: false, index: {using: :btree}
      t.timestamps_with_timezone null: false

      t.index [:name, :parent_category_id], using: :btree, unique: true

      t.check_constraint "name IS NOT NULL AND name <> ''", name: :check_product_categories_name_presence
      t.check_constraint "CHAR_LENGTH(name) <= 255 AND CHAR_LENGTH(name) >= 2", name: :check_product_categories_name_length
    end
  end
end
