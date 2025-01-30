# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class EnableUuid < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto"
  end
end
