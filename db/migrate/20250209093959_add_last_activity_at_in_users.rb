# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AddLastActivityAtInUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :last_activity_at, :timestamptz
  end
end
