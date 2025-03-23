# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module FlashMessages
  extend ActiveSupport::Concern

  included do
    def render_flash
      turbo_stream.update(:flash_messages_frame, partial: "shared/flash_messages")
    end
  end

  private

  # Sets flash messages with dynamic scope based on controller and action
  def set_flash_message(type, message_key, immediate: false, scope: nil, **options)
    flash_type = immediate ? flash.now : flash
    scope ||= "flashes.#{controller_name}.#{action_name}" # Default scope if not provided

    flash_type[type] = t(message_key, scope:, **options)
  end
end
