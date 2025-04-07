# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Provides a convenient and safe way to render partials, templates, or data formats
# (JSON, XML) only if they exist or match the request format.
#
# @example Rendering a partial safely
#   safe_render.partial("shared/some_partial", locals: { foo: "bar" })
#
# @example Rendering with a block
#   safe_render.partial("shared/modal") do
#     content_tag(:p, "Inside modal")
#   end
#
# @example Rendering template safely
#   safe_render.template("users/show", locals: { user: @user })
#
# @example Rendering JSON safely
#   safe_render.json({ hello: "world" })
#
# @example Rendering XML safely
#   safe_render.xml({ hello: "world" })
module SafeRenderHelper
  # Returns a memoized instance of SafeRenderer bound to the current view context.
  #
  # @return [SafeRenderer] an instance used to safely render views
  def safe_render
    @safe_render ||= SafeRenderer.new(self)
  end

  # Custom exception class for SafeRenderer context errors
  class SafeRendererContextError < StandardError; end

  # Encapsulates logic for rendering partials, templates, JSON, or XML only if safe.
  class SafeRenderer
    # @return [ActionView::Base] The current rendering context
    attr_reader :context

    # Initializes the renderer with the view context.
    #
    # @param context [ActionView::Base] the context in which rendering happens
    def initialize(context)
      @context = context
    end

    # Safely renders a partial if it exists.
    #
    # @param partial [String] the name of the partial (e.g., "shared/card")
    # @param options [Hash] options such as :locals, :object, etc.
    # @yield optional block content to pass to the partial
    # @return [String, nil] rendered output or nil if partial not found
    def partial(partial, options = {}, &block)
      return unless lookup_context_exists?(partial, partial: true)

      context.render(partial, **options, &block)
    end

    # Safely renders a template if it exists.
    #
    # @param template [String] the name of the template (e.g., "users/index")
    # @param options [Hash] options such as :locals, :layout, etc.
    # @yield optional block content to pass to the template
    # @return [String, nil] rendered output or nil if template not found
    def template(template, options = {}, &block)
      return unless lookup_context_exists?(template, partial: false)

      context.render(template: template, **options, &block)
    end

    # Renders JSON only if request format is :json.
    #
    # @param object [Object] the object to render as JSON
    # @param options [Hash] additional options passed to `render`
    # @return [String, nil] rendered JSON or nil if format is not :json
    def json(object, options = {})
      return unless render_format?(:json)

      context.render(json: object, **options)
    end

    # Renders XML only if request format is :xml.
    #
    # @param object [Object] the object to render as XML
    # @param options [Hash] additional options passed to `render`
    # @return [String, nil] rendered XML or nil if format is not :xml
    def xml(object, options = {})
      return unless render_format?(:xml)

      context.render(xml: object, **options)
    end

    private

    # Checks whether the specified partial or template exists in the lookup context.
    #
    # @param name [String] the name of the partial or template
    # @param partial [Boolean] whether it's a partial (true) or template (false)
    # @return [Boolean] true if the view exists
    def lookup_context_exists?(name, partial:)
      lookup_context.exists?(name, [], partial)
    end

    def lookup_context
      if context.respond_to?(:lookup_context)
        context.lookup_context
      elsif context.respond_to?(:view_context)
        context.view_context.lookup_context
      else
        raise SafeRendererContextError, "SafeRenderer needs a context that responds to `lookup_context`"
      end
    end

    # Checks if the request format matches the given symbol (e.g., :json, :xml).
    #
    # @param format [Symbol] the expected format (e.g., :json, :xml)
    # @return [Boolean] true if the request format matches or fallback in case of error
    def render_format?(format)
      context.respond_to?(:render) &&
        context.respond_to?(:request) &&
        context.request.format.symbol == format
    rescue NoMethodError, StandardError
      true
    end
  end
end
