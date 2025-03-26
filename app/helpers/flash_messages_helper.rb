# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper methods for creating flash messages within the application.
#
module FlashMessagesHelper
  FLASH_TYPES = {
    notice: {variant: :success, icon: "face-smile"},
    alert: {variant: :danger, icon: "face-frown"},
    warning: {variant: :warning, icon: "exclamation-triangle"},
    info: {variant: :info, icon: "info-circle"}
  }.with_indifferent_access.freeze

  def flash_messages(options = {})
    flash.map do |msg_type, messages|
      next if messages.blank?

      next unless FLASH_TYPES.key?(msg_type)

      Array(messages).map { |message| build_flash_message(msg_type, message) }
    end.flatten.compact.join("\n").html_safe
  end

  private

  def build_flash_message(msg_type, message)
    tag.div(class: "alert alert-#{FLASH_TYPES.dig(msg_type, :variant)} d-flex align-items-center alert-dismissible fade show") do
      concat(external_svg_tag("svgs/#{FLASH_TYPES.dig(msg_type, :icon)}.svg", width: "24px", height: "24px", fill: "currentColor", class: "flex-shrink-0 me-2"))
      concat(tag.div(message))
      concat(tag.button("", class: "btn-close", "data-bs-dismiss" => "alert", "aria-label" => "Close"))
    end
  end
end
