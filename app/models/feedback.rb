# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Feedback < ApplicationRecord
  include Sortable, Pageable

  LISTING_ATTRIBUTES = %i[user_id reviewable rating comment].freeze

  attribute :is_unread, default: true

  belongs_to :user, inverse_of: :feedbacks
  belongs_to :reviewable, inverse_of: :feedbacks, polymorphic: true

  default_scope -> { order_created_desc }

  class << self
    def accessible(user)
      all
    end
  end
end
