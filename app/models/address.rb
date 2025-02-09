# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Address < ApplicationRecord

  validates :address1,
            presence: true,
            length: {maximum: 100},
            reduce: true
  validates :address2,
            length: {maximum: 100},
            allow_blank: true,
            reduce: true
  validates :postal_code,
            length: {maximum: 20},
            allow_blank: true,
            reduce: true
  validates :country, presence: true, reduce: true

  belongs_to :addressable, polymorphic: true

  def country_data
    ISO3166::Country[country]
  end

  def state_name
    country_data.subdivisions[state].name if state.present?
  end

  def country_name
    country_data.common_name
  end

  def humanize
    [
      address1, address2, city, state_name, country_name, postal_code
    ].compact.reject(&:blank?).join(", ")
  end
end
