# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Feedback < ApplicationRecord
  include Sortable, Pageable

  LISTING_ATTRIBUTES = %i[user_id reviewable rating comment].freeze

  attribute :is_unread, default: true

  validates :rating,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 10
            },
            reduce: true
  validate :rating_in_valid_steps
  validates :comment,
            presence: true,
            length: {maximum: 1000},
            reduce: true

  belongs_to :user, inverse_of: :feedbacks
  belongs_to :reviewable, inverse_of: :feedbacks, polymorphic: true

  scope :unread, -> { where(arel_table[:is_unread].eq(true)) }
  scope :read, -> { where(arel_table[:is_unread].eq(false)) }
  default_scope -> { order_created_desc }

  class << self
    def accessible(user)
      all
    end
  end

  def mark_as_read!
    update!(is_unread: false) if is_unread?
  end

  private

  def rating_in_valid_steps
    return if rating.nil?

    errors.add(:rating, :invalid) unless (rating * 2) == (rating * 2).floor
  end
end
