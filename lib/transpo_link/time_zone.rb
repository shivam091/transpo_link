# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TranspoLink
  module TimeZone
    extend self

    def formatted_time_zone(time_zone)
      offset = ActiveSupport::TimeZone[time_zone]&.utc_offset
      return nil unless offset

      "(GMT #{formatted_offset(offset)}) #{time_zone}"
    end

    def formatted_offset(offset)
      ActiveSupport::TimeZone.seconds_to_utc_offset(offset)
    end

    def select_options
      ActiveSupport::TimeZone.all.map do |tz|
        [formatted_time_zone(tz.name), tz.tzinfo.name]
      end
    end

    def with_user_time_zone(user, &block)
      Time.use_zone(user&.preferred_time_zone, &block)
    end

    def with_default_time_zone(&block)
      Time.use_zone(Time.zone_default, &block)
    end
  end
end
