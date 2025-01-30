# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module ApplicationHelper
  def render_if_exists(partial, locals: {}, &block)
    render(partial, locals, &block) if partial_exists?(partial)
  end

  def partial_exists?(partial)
    lookup_context.exists?(partial, [], true)
  end

  def template_exists?(template)
    lookup_context.exists?(template, [], false)
  end

  def copyright_year
    copyright_start_year, copyright_end_year = 2025, Date.current.year

    if copyright_start_year.eql?(copyright_end_year)
      copyright_end_year
    else
      "#{copyright_start_year} - #{copyright_end_year}"
    end
  end

  # Returns active css class when condition returns true
  # otherwise returns nil.
  #
  # Example:
  #   %li{ class: active_when(params[:filter] == '1') }
  def active_when(condition)
    "active" if condition
  end

  # Check if a particular controller is the current one
  #
  # args - One or more controller names to check (using path notation when inside namespaces)
  #
  # Examples
  #
  #   # On OrdersController
  #   current_controller?(:orders)           # => true
  #   current_controller?(:invoices)         # => false
  #
  #   # On Admin::ProductsController
  #   current_controller?(:products)         # => true
  #   current_controller?("products")        # => true
  def current_controller?(*args)
    args.any? do |v|
      TranspoLink::Utils.safe_downcase!(v.to_s).in?([controller.controller_name, controller.controller_path])
    end
  end

  # Check if a particular action is the current one
  #
  # args - One or more action names to check
  #
  # Examples
  #
  #   # On Orders#new
  #   current_action?(:new)           # => true
  #   current_action?(:create)        # => false
  #   current_action?(:new, :create)  # => true
  def current_action?(*args)
    args.any? { |v| TranspoLink::Utils.safe_downcase!(v.to_s) == action_name }
  end

  def secret_reveal_button(for_devise_views: false)
    tag.button(type: :button, class: "btn-secret-reveal") do
      concat(external_svg_tag("svgs/eye-visible.svg"))
      concat(external_svg_tag("svgs/eye-hidden.svg", class: "d-none"))
    end
  end

  # <% title @post.title %>
  def title(*text)
    title_text = [text, t("title")]
    content_for :title, title_text.join(" &middot; ").html_safe
  end

  def button_text(key)
    t(key, scope: "button_texts")
  end
end
