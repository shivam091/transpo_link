# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class RequestLog < ApplicationRecord
  include Sortable, Pageable

  normalizes :method, with: -> method { method.upcase }

  belongs_to :user, optional: true, inverse_of: :request_logs

  default_scope -> { order_created_desc }
end
