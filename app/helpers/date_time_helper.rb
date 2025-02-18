# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper methods for dealing with date and time.
#
module DateTimeHelper
  def time_ago(from_time, to_time = Time.zone.now, options = {})
    options = {
      scope: "datetime.time_ago",
      locale: TranspoLink::I18n.locale
    }.merge!(options)

    distance_in_seconds = (to_time.to_time - from_time.to_time).abs.round
    distance_in_minutes = (distance_in_seconds / 60).round

    I18n.with_options(**options) do |locale|
      return locale.t(:about_x_seconds_ago, count: distance_in_seconds) if distance_in_seconds < 60

      case distance_in_minutes
      when 1            then locale.t(:about_x_minutes_ago, count: 1)
      when 2..59        then locale.t(:about_x_minutes_ago, count: distance_in_minutes)
      when 60..89       then locale.t(:about_x_hours_ago, count: 1)
      when 90..1439     then locale.t(:about_x_hours_ago, count: (distance_in_minutes.to_f / 60).round)
      when 1440..2159   then locale.t(:about_x_days_ago, count: 1)
      when 2160..2880   then locale.t(:about_x_days_ago, count: (distance_in_minutes.to_f / 1440).round)
      else
        distance_in_days = (distance_in_minutes / 1440).round
        case distance_in_days
        when 0..7       then locale.t(:about_x_days_ago, count: distance_in_days)
        when 8..28      then locale.t(:about_x_weeks_ago, count: distance_in_days / 7)
        when 29..30     then locale.t(:about_x_weeks_and_x_days_ago, weeks: distance_in_days / 7, count: distance_in_days - 28)
        when 31..60     then locale.t(:about_x_months_ago, count: 1)
        when 61..364    then locale.t(:about_x_months_ago, count: (distance_in_days.to_f / 30).round)
        when 365..1092  then locale.t(:about_x_years_ago, count: (distance_in_days.to_f / 365.24).round)
        when 1093..1825 then locale.t(:over_x_years_ago, count: (distance_in_days.to_f / 365.24).round)
        else                 locale.t(:almost_x_years_ago, count: (distance_in_days.to_f / 365.24).round)
        end
      end
    end
  end

  def time_ago_with_tooltip(time, options = {})
    return unless time.present?

    options = {placement: "top", html_class: "", short_format: false}.merge!(options)

    css_classes = [options[:short_format] ? "js-short-timeago" : "js-timeago"]
    css_classes << options[:html_class] unless options[:html_class].blank?
    tag.time(
      time_ago(time),
      class: css_classes.join(" "),
      datetime: time.to_time.getutc.iso8601,
      data: {
        controller: "tooltip",
        bs_title: time.to_fs(:long),
        bs_placement: options[:placement]
      }
    )
  end
end
