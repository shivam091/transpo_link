# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module Breadcrumbs
  extend ActiveSupport::Concern

  included do
    extend ClassMethods
    helper HelperMethods

    helper_method :breadcrumbs, :add_breadcrumb
  end

  # Pushes a new breadcrumb element into the collection.
  def add_breadcrumb(label, url = nil, options = {})
    breadcrumbs << {label: compute_label(label, options), url: compute_url(url)}
  end

  # Gets the list of all breadcrumb element in the collection.
  def breadcrumbs
    @breadcrumbs ||= []
  end

  private

  def compute_label(label, options = {})
    case label
    when Symbol then t(label, **options.reverse_merge(scope: "breadcrumbs", default: label.to_s.humanize))
    when Proc   then label.call
    else             label.to_s
    end
  end

  def compute_url(url)
    case url
    when Symbol then send(url)
    when Proc   then url.call
    else             url
    end
  end

  module ClassMethods
    def add_breadcrumb(label, url = nil, options = {})
      before_action(options) do |controller|
        controller.send(:add_breadcrumb, label, url, options)
      end
    end
  end

  module HelperMethods

    # Renders the breadcrumb navigation as HTML
    def render_breadcrumbs
      return unless breadcrumbs.any?

      tag.nav(aria: {label: "breadcrumb"}) do
        tag.ol(class: "breadcrumb") do
          safe_join(breadcrumbs.map.with_index do |crumb, index|
            if crumb[:url] && index != breadcrumbs.size - 1
              tag.li(class: "breadcrumb-item") do
                link_to(crumb[:label], crumb[:url])
              end
            else
              tag.li(crumb[:label], class: "breadcrumb-item active", aria: {current: "page"})
            end
          end)
        end
      end
    end
  end
end
