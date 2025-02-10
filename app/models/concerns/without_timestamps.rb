# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Mixin module to temporarily turn off time-stamping in a block.
#
# Usage:
#
#   class MyModel < ActiveRecord::Base
#     include WithoutTimestamps
#
#     def save_without_timestamps
#       MyModel.without_timestamps do
#         save!
#       end
#     end
#   end
#
module WithoutTimestamps
  extend ActiveSupport::Concern

  class_methods do
    def without_timestamps
      original_state = ActiveRecord::Base.record_timestamps
      ActiveRecord::Base.record_timestamps = false

      yield
    rescue StandardError => e
      Rails.logger.error("#{e.message}\n#{e.backtrace.first(3).join("\n")}")
      raise
    ensure
      ActiveRecord::Base.record_timestamps = original_state
    end
  end
end
