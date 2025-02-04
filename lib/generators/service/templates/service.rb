# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class <%= normalized_class_name %>Service < ApplicationService
  def initialize
  end
  def call
<% if methods.any? -%>
<% methods.each do |method| -%>
    <%= method %>
<% end -%>
<% end -%>
  end
<% if methods.any? -%>
  private
<% methods.each do |method| -%>
  def <%= method %>
  end
<% end -%>
<% end -%>
end
