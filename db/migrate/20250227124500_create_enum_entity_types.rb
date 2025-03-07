# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class CreateEnumEntityTypes < ActiveRecord::Migration[8.0]
  def change
    create_enum :entity_types, %i[business individual]
  end
end
