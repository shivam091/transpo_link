# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module ColorSchemesHelper
  COLOR_SCHEME_ICONS = {
    auto: "device-desktop",
    light: "sun",
    dark: "moon"
  }.with_indifferent_access.tap { |hash| hash.default = hash.fetch(:auto) }.freeze

  def color_scheme_icon_for(color_scheme)
    COLOR_SCHEME_ICONS.fetch(color_scheme, COLOR_SCHEME_ICONS.default)
  end
end
