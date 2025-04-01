# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumTaxTypes < ActiveRecord::Migration[8.0]
  def change
    create_enum :tax_types, %i[exclusive inclusive]
  end
end
