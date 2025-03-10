# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class Feedback < ApplicationRecord
  attribute :is_unread, default: true

  belongs_to :user, inverse_of: :feedbacks
  belongs_to :reviewable, inverse_of: :feedbacks, polymorphic: true
end
