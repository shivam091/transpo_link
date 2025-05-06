# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class RequestLog < ApplicationRecord
  include Sortable, Pageable, Navigable, ScaleEnforcer

  LISTING_ATTRIBUTES = %i[uuid uri method remote_address status created_at user_id].freeze

  normalizes :method, with: ->(method) { method.upcase }

  scale_attributes :cpu_usage, :elapsed_time

  belongs_to :user, optional: true, inverse_of: :request_logs
end
