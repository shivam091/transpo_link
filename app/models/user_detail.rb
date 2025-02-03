# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class UserDetail < ApplicationRecord
  self.primary_key = :user_id

  belongs_to :user, inverse_of: :user_detail

  def full_name
    "#{try(:first_name)} #{try(:last_name)}"
  end
end
