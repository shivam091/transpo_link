# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreatePoReferenceCodeSequence < ActiveRecord::Migration[8.0]
  def change
    create_sequence :po_reference_code_seq, owned_by: "purchase_orders.reference_code"
  end
end
