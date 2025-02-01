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
  delegate :preferred_locale, :preferred_locale=,
           :preferred_time_zone, :preferred_time_zone=,
           :preferred_color_scheme, :preferred_color_scheme=,
           :preferred_currency, :preferred_currency=,
           :are_notifications_enabled, :are_notifications_enabled=,
           to: :user_preference

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

  def user_detail
    super.presence || build_user_detail
  end

  def user_preference
    super.presence || build_user_preference
  end
end
