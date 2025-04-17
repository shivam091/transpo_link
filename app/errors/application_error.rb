# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class ApplicationError < StandardError
  attr_reader :i18n_key, :context

  def initialize(i18n_key = :unknown, context: {})
    @i18n_key = i18n_key
    @context = context

    super(message)
  end

  def message
    I18n.t(i18n_key, scope: default_scope, **context)
  end

  def default_scope
    "errors"
  end
end
