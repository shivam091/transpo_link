# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumColorSchemes < ActiveRecord::Migration[8.0]
  def change
    create_enum :color_schemes, %i[auto dark light]
  end
end
