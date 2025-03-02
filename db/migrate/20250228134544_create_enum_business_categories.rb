# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumBusinessCategories < ActiveRecord::Migration[8.0]
  def change
    create_enum :business_categories, %i[b2b b2c]
  end
end
