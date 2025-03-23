# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AddReferenceCodeInFeedbacks < ActiveRecord::Migration[8.0]
  def change
    add_column :feedbacks, :reference_code, :string
    add_index :feedbacks, :reference_code, using: :btree, unique: true
  end
end
