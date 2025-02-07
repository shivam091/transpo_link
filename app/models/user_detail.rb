# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UserDetail < ApplicationRecord
  self.primary_key = :user_id

  validates :first_name, :last_name,
            presence: true,
            length: {in: 2..55},
            reduce: true
  validates :mobile_number, :alternate_contact_number, :alternate_email,
            length: {in: 2..55},
            allow_blank: true,
            reduce: true

  belongs_to :user, inverse_of: :user_detail

  def full_name
    "#{try(:first_name)} #{try(:last_name)}"
  end
end
