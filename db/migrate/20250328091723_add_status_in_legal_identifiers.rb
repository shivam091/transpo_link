# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AddStatusInLegalIdentifiers < ActiveRecord::Migration[8.0]
  include TranspoLink::MigrationHelpers

  def change
    add_column :legal_identifiers, :status, :enum, enum_type: :legal_identifier_statuses

    add_index :legal_identifiers, :status, using: :btree

    add_check_constraint :legal_identifiers, "status IS NOT NULL", name: :check_legal_identifiers_status_presence
    add_check_constraint :legal_identifiers, "status IN (#{enum_values('legal_identifier_statuses')})", name: :check_legal_identifiers_status_inclusion
  end
end
