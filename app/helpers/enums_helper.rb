# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper methods for internationalization of enums.
#
module EnumsHelper
  # Returns an array of the possible key/i18n values for the enum.
  #
  # ```
  #   enum_options_for_select(UserPreference, :color_scheme)
  # ```
  def enum_options_for_select(model, enum)
    model.send(enum.to_s.pluralize).map do |key, value|
      [enum_i18n(model, enum, key), value]
    end
  end

  # Returns the i18n version the models current enum key.
  #
  # ```
  #   enum_l(user_preference, :color_scheme)
  # ```
  def enum_l(model, enum)
    enum_i18n(model.class, enum, model.send(enum))
  end

  # Returns the i18n string for the enum key.
  #
  # ```
  #   enum_i18n(UserPreference, :color_scheme, :dark)
  # ```
  def enum_i18n(model, enum, key)
    I18n.t("#{key}", scope: "enumerations.#{model.model_name.i18n_key}.#{enum.to_s.pluralize}")
  end

  # Get the key for an enum value (reverse lookup)
  #
  # ```
  #   enum_key(UserPreference, :preferred_color_schemes, "auto")
  # ```
  def enum_key(model, enum, value)
    model.send(enum.to_s.pluralize).key(value)
  end
end
