# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateProductReferenceCodeSequence < ActiveRecord::Migration[8.0]
  def change
    create_sequence :product_reference_code_seq, owned_by: "products.reference_code"
  end
end
