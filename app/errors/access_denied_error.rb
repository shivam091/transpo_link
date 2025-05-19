# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class AccessDeniedError < ApplicationError
  def initialize(module_key, action_key)
    super(:access_denied, context: {module_key:, action_key:})
  end
end
