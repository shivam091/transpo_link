# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module Presentable
  def decorate(view_context = nil)
    "#{self.class}Presenter".constantize.new(self, view_context)
  end
end
