# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class TaxRate < ApplicationRecord
  include Pageable, Taxable, Sortable, NullifyIfBlank

  LISTING_ATTRIBUTES = %i[
    country tax_identifier_type business_category rate valid_from valid_to
  ].freeze

  enum :business_category, {
    b2b: "b2b",
    b2c: "b2c"
  }

  attribute :business_category, :enum, default: business_categories[:b2b]

  nullify_if_blank :valid_to

  validates :tax_identifier_type,
            uniqueness: {
              scope: [:country, :business_category, :valid_from],
              message: :uniqueness
            },
            reduce: true
  validates :business_category,
            presence: true,
            inclusion: {in: business_categories.values, message: :inclusion},
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
            reduce: true
  validates :valid_from,
            comparison: {
              greater_than_or_equal_to: Date.current,
              message: :greater_than_or_equal_to
            },
            on: :create,
            reduce: true
  validates :valid_to,
            comparison: {greater_than: :valid_from},
            allow_nil: true,
            reduce: true
  validate :no_overlapping_tax_rates
  validate :cannot_change_rate_for_active_tax_rate, on: :update

  # Scope to get active tax rates (valid for today)
  scope :active, -> {
    where(
      arel_table[:valid_from].lteq(Date.current)
        .and(arel_table[:valid_to].eq(nil)
          .or(arel_table[:valid_to].gteq(Date.current)))
    )
  }

  # Scope to get future tax rates
  scope :future, -> { where(arel_table[:valid_from].gt(Date.current)) }

  # Scope to get tax rates whose valid_to has passed
  scope :expired, -> { where(arel_table[:valid_to].lt(Date.current)) }

  # Scope to get tax rates for a specific country
  scope :for_country, ->(country) { where(arel_table[:country].eq(country)) }

  # Scope to get tax rates for a specific tax identifier type
  scope :for_tax_identifier_type, ->(tax_identifier_type) { where(arel_table[:tax_identifier_type].eq(tax_identifier_type)) }

  # Scope for filtering by category
  scope :for_category, ->(category) { where(arel_table[:business_category].eq(category)) }

  # Scope for applicable tax rates based on type, country, and category
  scope :applicable_rates, ->(type, country, category) {
    for_tax_identifier_type(type).for_country(country).for_category(category)
  }

  # Scope to find tax rates valid on a specific date
  scope :valid_on, ->(date) {
    where(
      arel_table[:valid_from].lteq(date)
        .and(arel_table[:valid_to].eq(nil)
          .or(arel_table[:valid_to].gteq(date)))
    )
  }

  default_scope -> { order_created_desc }

  class << self
    def active_rate(country, tax_identifier_type)
      for_country(country).for_tax_identifier_type(tax_identifier_type).active.order(arel_table[:valid_from].desc).first
    end

    # Returns the tax rate for a future date
    def future_rate(country, tax_identifier_type, date)
      for_country(country).for_tax_identifier_type(tax_identifier_type).valid_on(date).order(arel_table[:valid_from].desc).first
    end
  end

  private

  # Prevent overlapping tax rates for the same country and tax identifier type
  def no_overlapping_tax_rates
    tax_rates = TaxRate.arel_table
    scope = TaxRate.where(
      tax_rates[:country].eq(country)
        .and(tax_rates[:tax_identifier_type].eq(tax_identifier_type))
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
