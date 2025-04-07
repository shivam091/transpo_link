# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# This helper provides a convenient and safe way to render partials or templates
# in views without raising an error when they don't exist. Instead of raising
# exceptions, it silently returns `nil` when the given template/partial is not found.
#
# Usage in a view or helper:
#   safe_render.partial("shared/header", user: current_user)
#   safe_render.template("admin/dashboard", layout: false)
#
module SafeRenderHelper
  # Returns a memoized instance of SafeRenderer bound to the current view context.
  #
  # @return [SafeRenderer] an instance used to safely render views
  def safe_render
    @safe_render ||= SafeRenderer.new(self)
  end

  # SafeRenderer encapsulates logic for rendering views with built-in existence checks.
  class SafeRenderer
    attr_reader :view

    # Initializes a new SafeRenderer instance with a given view context.
    #
    # @param view_context [ActionView::Base] the current view context
    def initialize(view_context)
      @view = view_context
    end

    # Safely renders a partial if it exists in the view path.
    #
    # @param partial [String] the path to the partial
    # @param options [Hash] rendering options like :locals
    # @yield Optional block to be passed to the renderer
    # @return [String, nil] rendered partial or nil if not found
    def partial(partial, options = {}, &block)
      return unless view.lookup_context.exists?(partial, [], true)

      view.render(partial, **options, &block)
    end

    # Safely renders a template (non-partial) if it exists.
    #
    # @param template [String] the path to the template
    # @param options [Hash] rendering options like :layout, :locals
    # @yield Optional block to be passed to the renderer
    # @return [String, nil] rendered template or nil if not found
    def template(template, options = {}, &block)
      return unless view.lookup_context.exists?(template, [], false)

      view.render(template: template, **options, &block)
    end
  end
end
