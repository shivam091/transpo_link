# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Feedback < ApplicationRecord
  include Sortable, Pageable, HasReferenceCode, Sanitizable, Navigable

  LISTING_ATTRIBUTES = %i[reference_code user_id reviewable rating comment].freeze

  attribute :is_unread, default: true

  sanitize_attributes :comment

  validates :rating,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 10
            },
            reduce: true
  validates :comment,
            presence: true,
            length: {maximum: 1000},
            reduce: true

  validate :rating_in_valid_steps

  with_options inverse_of: :feedbacks do |a|
    a.belongs_to :user
    a.belongs_to :reviewable, polymorphic: true
  end

  scope :unread, -> { where(arel_table[:is_unread].eq(true)) }
  scope :read, -> { where(arel_table[:is_unread].eq(false)) }

  class << self
    def accessible(user)
      return user.feedbacks unless user.admin?

      all
    end

    # Unread feedbacks for a specific user.
    def unread_for_user(user)
      where(arel_table[:user_id].eq(user.id).and(arel_table[:is_unread].eq(true)))
    end

    # Average rating for a specific reviewable entity.
    def average_rating_for(reviewable)
      avg_rating = TranspoLink::SqlFunctions.avg(arel_table[:rating])
      query = arel_table.project(avg_rating)
        .where(
          arel_table[:reviewable_type].eq(reviewable.class.name)
            .and(arel_table[:reviewable_id].eq(reviewable.id))
        )

      connection.select_value(query.to_sql).to_f.round(1)
    end

    # Fetch feedback for a specific user and reviewable object.
    def for_user_and_reviewable(user, reviewable)
      where(
        arel_table[:user_id].eq(user.id)
          .and(arel_table[:reviewable_type].eq(reviewable.class.name))
          .and(arel_table[:reviewable_id].eq(reviewable.id))
      )
    end
  end

  def mark_as_read!
    update!(is_unread: false) if is_unread?
  end

  def key_associations
    [user, reviewable]
  end

  private

  def rating_in_valid_steps
    return unless rating.present?

    errors.add(:rating, :invalid) unless (rating % 0.5).zero?
  end
end
