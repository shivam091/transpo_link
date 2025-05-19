# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module PermissionsHelper
  def translate_module(label_key)
    I18n.t(label_key, scope: "permissions.modules")
  end

  def translate_action(label_key)
    I18n.t(label_key, scope: "permissions.actions")
  end
end
