# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module PresentersHelper
  def present(model, presenter_class = nil)
    clazz = presenter_class || "#{model.class}Presenter".constantize
    presenter = clazz.new(model, self)
    yield(presenter) if block_given?
  end
end
