# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateWarehouseReferenceCodeSequence < ActiveRecord::Migration[8.0]
  def change
    create_sequence :warehouse_reference_code_seq, owned_by: "warehouses.reference_code"
  end
end
