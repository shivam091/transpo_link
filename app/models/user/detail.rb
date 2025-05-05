# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class User::Detail < ApplicationRecord
  include NullifyIfBlank, Sanitizable

  self.primary_key = :user_id

  normalizes :first_name, with: ->(first_name) { first_name.strip }
  normalizes :last_name, with: ->(last_name) { last_name.strip }

  nullify_if_blank :mobile_number, :alternate_contact_number, :alternate_email

  sanitize_attributes :first_name, :last_name, :mobile_number, :alternate_contact_number,
                      :alternate_email

  validates :user_id,
            presence: true,
            reduce: true
  validates :first_name, :last_name,
            presence: true,
            length: {in: 2..55},
            reduce: true
  validates :mobile_number, :alternate_contact_number, :alternate_email,
            length: {in: 2..55},
            allow_blank: true,
            reduce: true

  belongs_to :user, inverse_of: :detail, touch: true

  def full_name
    "#{try(:first_name)} #{try(:last_name)}"
  end
end
