# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class EnableBtreeGist < ActiveRecord::Migration[8.0]
  def change
    enable_extension "btree_gist"
  end
end
