# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class User < ApplicationRecord
  include Toggleable, CaseSensitivity, WithoutTimestamps, Pageable, Sanitizable,
          Navigable

  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :validatable, :timeoutable, :trackable

  LAST_ACTIVITY_AT_INTERVAL = 2.minutes.freeze
  THROTTLE_RESET_PERIOD = 2.minutes.freeze

  attribute :is_banned, default: false
  attribute :is_active, default: false

  normalizes :email, with: ->(email) { email.strip }

  sanitize_attributes :email, :password, :password_confirmation

  validates :role_id,
            presence: true,
            reduce: true
  validates :email,
            presence: true,
            length: {in: 2..55},
            email: true,
            uniqueness: {case_sensitive: true},
            reduce: true
  validates :password,
            presence: true,
            password: true,
            length: {in: 8..20},
            reduce: true,
            if: :password_required?

  with_options inverse_of: :user do |a|
    a.has_one :detail, class_name: "User::Detail", dependent: :destroy, autosave: true
    a.has_one :preference, class_name: "User::Preference", dependent: :destroy, autosave: true

    a.has_many :request_logs, dependent: :nullify
    a.has_many :legal_identifiers, dependent: :destroy
    a.has_many :inventory_audit_logs, class_name: "Inventory::AuditLog", dependent: :nullify
    a.has_many :inventory_batch_audit_logs, class_name: "Inventory::Batch::AuditLog", dependent: :nullify
    a.has_many :feedbacks, dependent: :nullify
  end

  with_options dependent: :restrict_with_exception do |a|
    a.has_many :purchase_orders, inverse_of: :manager
    a.has_many :supplied_purchase_orders, inverse_of: :supplier, class_name: "PurchaseOrder"
    a.has_many :warehouse_managers, class_name: "Warehouse::Manager", inverse_of: :manager, foreign_key: :manager_id
    a.has_many :warehouse_suppliers, class_name: "Warehouse::Supplier", inverse_of: :supplier, foreign_key: :supplier_id
  end

  has_one :address, as: :addressable, inverse_of: :addressable, dependent: :destroy

  has_many :managed_warehouses, through: :warehouse_managers, inverse_of: :managers, source: :warehouse
  has_many :supplied_warehouses, through: :warehouse_suppliers, inverse_of: :suppliers, source: :warehouse

  belongs_to :role, inverse_of: :users

  after_update :update_password_updated_at, if: :saved_change_to_encrypted_password?

  scope :suspended, -> { where(arel_table[:is_banned].eq(true)) }
  scope :admins, -> { with_role("admin") }
  scope :suppliers, -> { with_role("supplier") }
  scope :buyers, -> { with_role("buyer") }
  scope :managers, -> { with_role("manager") }

  delegate :name, to: :role, prefix: true
  delegate :first_name, :last_name, :full_name, :mobile_number,
           :alternate_email, :alternate_contact_number,
           to: :detail
  delegate :preferred_locale, :preferred_locale=,
           :preferred_time_zone, :preferred_time_zone=,
           :preferred_color_scheme, :preferred_color_scheme=,
           :preferred_currency, :preferred_currency=,
           :preferred_date_format, :preferred_date_format=,
           :preferred_time_format, :preferred_time_format=,
           :preferred_datetime_format, :preferred_datetime_format=,
           :first_day_of_week, :first_day_of_week=,
           :are_notifications_enabled, :are_notifications_enabled=,
           :enable_keyboard_shortcuts, :enable_keyboard_shortcuts=,
           to: :preference

  accepts_nested_attributes_for :detail, update_only: true
  accepts_nested_attributes_for :preference, update_only: true
  accepts_nested_attributes_for :address, update_only: true

  class << self
    def with_email(email)
      iwhere(email: email.strip).first
    end

    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      email = conditions.delete(:email)
      where(conditions).with_email(email)
    end

    def select_options
      all.includes(:detail).collect { |user| [user.full_name, user.id] }
    end

    def with_role(role_name)
      role_table = Role.arel_table
      user_table = User.arel_table
      join = user_table.join(role_table)
        .on(user_table[:role_id].eq(role_table[:id]))
        .join_sources
      joins(join).where(role_table[:name].eq(role_name))
    end
  end

  def active_for_authentication?
    super && is_active? && role.is_active?
  end

  def detail
    super.presence || build_detail
  end

  def preference
    super.presence || build_preference
  end

  def address
    super.presence || build_address
  end

  def update_last_activity_at
    return if new_record?
    return unless last_activity_at.to_i < (Time.now.utc - LAST_ACTIVITY_AT_INTERVAL).to_i

    update_column(:last_activity_at, Time.now.utc)
  end

  def recently_sent_password_reset_instructions?
    reset_password_sent_at.present? && reset_password_sent_at >= (Time.current - THROTTLE_RESET_PERIOD)
  end

  def admin?
    has_role?("admin")
  end

  def buyer?
    has_role?("buyer")
  end

  def supplier?
    has_role?("supplier")
  end

  def manager?
    has_role?("manager")
  end

  def has_role?(role)
    role.eql?(role_name)
  end

  # Returns the current day according to the user's time zone
  def today
    time_to_date(Time.current)
  end

  # Returns the day of the given time according to the user's time zone
  def time_to_date(time)
    convert_time_to_user_timezone(time).to_date
  end

  # Converts time to the user's preferred time zone
  def convert_time_to_user_timezone(time)
    return time unless time.is_a?(Time) || time.is_a?(DateTime) || time.is_a?(ActiveSupport::TimeWithZone)

    preferred_time_zone ? time.in_time_zone(preferred_time_zone) : time.in_time_zone
  end

  private

  def update_password_updated_at
    update_column(:password_updated_at, Time.now.utc)
  end
end
