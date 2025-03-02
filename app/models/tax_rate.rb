# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxRate < ApplicationRecord
  include Pageable, Taxable, Sortable

  enum :business_category, {
    b2b: "b2b",
    b2c: "b2c"
  }

  validates :tax_type,
            uniqueness: {
              scope: [:country, :business_category, :valid_from],
              message: :uniqueness
            },
            reduce: true
  validates :business_category,
            presence: true,
            inclusion: {
              in: business_categories.values,
              message: :inclusion
            },
            reduce: true
  validates :rate,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 100
            },
            reduce: true
  validates :valid_from,
            presence: true,
            comparison: {
              greater_than_or_equal_to: Date.current,
              message: :greater_than_or_equal_to
            },
            reduce: true
  validates :valid_to,
            comparison: {
              greater_than: :valid_from
            },
            allow_nil: true,
            reduce: true
  validate :no_overlapping_tax_rates
  validate :cannot_change_rate_for_active_tax_rate, on: :update

  default_scope -> { order_created_desc }
  private

  # Prevent overlapping tax rates for the same country and tax type
  def no_overlapping_tax_rates
    tax_rates = TaxRate.arel_table
    scope = TaxRate.where(
      tax_rates[:country].eq(country)
        .and(tax_rates[:tax_type].eq(tax_type))
        .and(tax_rates[:business_category].eq(business_category))
        .and(tax_rates[:valid_from].lt(valid_to))
        .and(tax_rates[:valid_to].eq(nil).or(tax_rates[:valid_to].gt(valid_from)))
    )

    scope = scope.where.not(tax_rates[:id].eq(id)) if persisted? # Exclude itself if updating

    if scope.exists?
      errors.add(:base, :no_overlapping_tax_rates)
    end
  end

  def cannot_change_rate_for_active_tax_rate
    return unless rate_changed?

    # Check if the tax rate is active and prevent changes
    if valid_from <= Date.current && (valid_to.nil? || valid_to >= Date.current)
      errors.add(:rate, :cannot_change_rate_for_active_tax_rate)
    end
  end
end
