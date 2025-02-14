# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper module containing methods for rendering modals.
#
module ModalsHelper
  MODAL_SIZE_CLASSES = {
    sm: "modal-sm",
    md: "modal-md",
    lg: "modal-lg",
    xl: "modal-xl"
  }.freeze

  DEFAULT_MODAL_OPTIONS = {
    title: "",
    modal_id: "modal-window"
  }.freeze

  def render_modal(options = {}, &block)
    options.reverse_merge!(DEFAULT_MODAL_OPTIONS)
    options[:size_class] ||= MODAL_SIZE_CLASSES[(options.delete(:size) || :md)]
    render_if_exists("shared/remote_modal", locals: options, &block)
  end
end
