# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateInventoryReferenceCodeSequence < ActiveRecord::Migration[8.0]
  def change
    create_sequence :inventory_reference_code_seq, owned_by: "inventories.reference_code"
  end
end
