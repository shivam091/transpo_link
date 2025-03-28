# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AddStatusInLegalIdentifiers < ActiveRecord::Migration[8.0]
  def change
    add_column :legal_identifiers, :status, :string

    add_index :legal_identifiers, :status, using: :btree
  end
end
