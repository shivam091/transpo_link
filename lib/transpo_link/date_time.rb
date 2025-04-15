# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TranspoLink
  module DateTime
    extend self

    DATE_FORMATS = %i[default short long long_with_day long_with_hyphen year_and_month].freeze

    TIME_FORMATS = %i[twelve_hours_long twelve_hours_short twenty_four_hours_short twenty_four_hours_long].freeze

    DATE_TIME_FORMATS = %i[
      default_twelve_hours
      default_twenty_four_hours
      short
      short_with_seconds
      long
      long_with_seconds
      twelve_hours_long_with_gmt_zone
      twenty_four_hours_long_with_gmt_zone
      twelve_hours_default_with_gmt_zone
      twenty_four_hours_default_with_gmt_zone
      twelve_hours_long_with_local_zone
      twenty_four_hours_long_with_local_zone
      twelve_hours_default_with_local_zone
      twenty_four_hours_default_with_local_zone
    ].freeze

    private_constant :DATE_FORMATS, :TIME_FORMATS, :DATE_TIME_FORMATS

    def date_format_options
      format_options(DATE_FORMATS, Date.current)
    end

    def time_format_options
      format_options(TIME_FORMATS, Time.current)
    end

    def date_time_format_options
      format_options(DATE_TIME_FORMATS, Time.current)
    end

    def date_format_select_options
      select_options(DATE_FORMATS, Date.current)
    end

    def time_format_select_options
      select_options(TIME_FORMATS, Time.current)
    end

    def date_time_format_select_options
      select_options(DATE_TIME_FORMATS, Time.current)
    end

    private

    def format_options(formats, sample_value = Time.current)
      formats.index_with { |key| ::I18n.l(sample_value, format: key) }
    end

    def select_options(formats, sample_value = Time.current)
      format_options(formats, sample_value).map { |key, val| [val, key] }
    end
  end
end
