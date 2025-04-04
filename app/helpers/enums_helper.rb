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
    enum_values(model, enum).map { |key, value| [enum_i18n(model, enum, key), value] }
  end

  # Returns the i18n version the models current enum key.
  #
  # ```
  #   enum_l(user_preference, :color_scheme)
  # ```
  def enum_l(model, enum)
    key = model.send(enum)

    key.present? ? enum_i18n(model.class, enum, key) : nil
  end

  # Returns the i18n string for the enum key.
  #
  # ```
  #   enum_i18n(UserPreference, :color_scheme, :dark)
  # ```
  def enum_i18n(model, enum, key)
    I18n.t(key.to_s, scope: enum_scope(model, enum), default: key.to_s.humanize)
  end

  # Get the key for an enum value (reverse lookup)
  #
  # ```
  #   enum_key(UserPreference, :color_scheme, "auto")
  # ```
  def enum_key(model, enum, value)
    enum_values(model, enum).key(value)
  end

  private

  # Helper to fetch enum values from the model.
  def enum_values(model, enum)
    model.public_send(enum.to_s.pluralize)
  end

  # Helper to construct the i18n scope.
  def enum_scope(model, enum)
    "enumerations.#{model.model_name.i18n_key}.#{enum.to_s.pluralize}"
  end
end
