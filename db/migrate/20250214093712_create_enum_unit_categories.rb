# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumUnitCategories < ActiveRecord::Migration[8.0]
  def change
    create_enum :unit_categories, %i[count length weight area volume]
  end
end
