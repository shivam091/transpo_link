# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AddPasswordUpdatedAtInUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :password_updated_at, :timestamptz
  end
end
