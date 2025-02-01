# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class User < ApplicationRecord
  include Toggleable, CaseSensitivity

  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :validatable, :timeoutable, :trackable

  attribute :is_active, default: false
  attribute :is_banned, default: false

  has_one :user_detail, inverse_of: :user, dependent: :destroy, autosave: true
  has_one :user_preference, inverse_of: :user, dependent: :destroy, autosave: true

  has_many :request_logs, inverse_of: :user, dependent: :nullify

  belongs_to :role, inverse_of: :users

  delegate :name, to: :role, prefix: true
  delegate :full_name, to: :user_detail

  class << self
    def with_email(email)
      iwhere(email: email.strip).first
    end

    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      email = conditions.delete(:email)
      where(conditions).with_email(email)
    end
  end
end
