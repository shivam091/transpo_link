# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module ActiveRecordHelpers
  def connection
    ActiveRecord::Base.connection
  end
end
