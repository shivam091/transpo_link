# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PurchaseOrder::Approval < ApplicationRecord
  include Sanitizable, NullifyIfBlank

  enum :incoterm_code, {
    exw: "EXW",
    fca: "FCA",
    fob: "FOB",
    cfr: "CFR",
    cif: "CIF",
    dap: "DAP",
    dpu: "DPU",
    ddp: "DDP",
  }

  enum :shipping_method, {
    air: "AIR",
    sea: "SEA",
    road: "ROAD",
    rail: "RAIL",
    courier: "COURIER",
    postal: "POSTAL",
    multimodal: "MULTIMODAL",
    drone: "DRONE",
    bike: "BIKE",
    hand_carry: "HAND_CARRY",
    in_person: "IN_PERSON",
  }

  nullify_if_blank :remarks

  sanitize_attributes :reference_document, :remarks, :payment_terms

  validates :reference_document,
            presence: true,
            length: {maximum: 55},
            reduce: true
  validates :expected_delivery_date,
            presence: true,
            comparison: {
              greater_than_or_equal_to: Date.current,
              message: :must_be_today_or_future_date
            },
            reduce: true
  validates :incoterm_code,
            presence: true,
            inclusion: {in: incoterm_codes.keys, message: :inclusion},
            reduce: true
  validates :shipping_method,
            presence: true,
            inclusion: {in: shipping_methods.keys, message: :inclusion},
            reduce: true
  validates :payment_terms,
            presence: true,
            length: {maximum: 1000},
            reduce: true
  validates :remarks,
            length: {maximum: 1000},
            allow_blank: true,
            reduce: true

  validate :expected_delivery_date_within_six_months

  belongs_to :purchase_order, inverse_of: :approval

  private

  def expected_delivery_date_within_six_months
    return if expected_delivery_date.blank?

    max_date = Date.current + 180.days

    if expected_delivery_date > max_date
      errors.add(:expected_delivery_date, :must_be_within_six_months)
    end
  end
end
