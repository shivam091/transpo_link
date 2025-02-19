# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class <%= normalized_class_name %>Presenter < ApplicationPresenter
<% if targets.any? -%>
  presents <%= target_list %>
<% end -%>
end
