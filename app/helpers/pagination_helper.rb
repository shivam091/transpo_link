# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module PaginationHelper
  def render_pagination(pagination_data)
    return "" if pagination_data[:total_pages] <= 1

    content = ActiveSupport::SafeBuffer.new

    content.safe_concat(tag.nav(aria: {label: t("pagination.label", default: "Pagination")}) do
      tag.ul(class: "pagination justify-content-center") do
        safe_concat(previous_page_tag(pagination_data))
        safe_concat(page_number_tags(pagination_data))
        safe_concat(next_page_tag(pagination_data))
      end
    end)

    content
  end

  private

  def previous_page_tag(pagination_data)
    tag.li(class: "page-item #{'disabled' unless pagination_data[:previous_page]}") do
      if pagination_data[:previous_page]
        tag.a(t("pagination.previous", default: "Previous"), href: url_for(page: pagination_data[:previous_page]), class: "page-link")
      else
        tag.span(t("pagination.previous", default: "Previous"), class: "page-link")
      end
    end
  end

  def next_page_tag(pagination_data)
    tag.li(class: "page-item #{'disabled' unless pagination_data[:next_page]}") do
      if pagination_data[:next_page]
        tag.a(t("pagination.next", default: "Next"), href: url_for(page: pagination_data[:next_page]), class: "page-link")
      else
        tag.span(t("pagination.next", default: "Next"), class: "page-link")
      end
    end
  end

  def page_number_tags(pagination_data)
    current_page = pagination_data[:current_page]
    total_pages = pagination_data[:total_pages]

    return full_page_range(current_page, total_pages) if total_pages < 8

    range = 2
    pages = [1]
    pages << "..." if (current_page - range) > 2
    ((current_page - range)..(current_page + range)).each { |p| pages << p if (p > 1) && (p < total_pages) }
    pages << "..." if (current_page + range) < (total_pages - 1)
    pages << total_pages if total_pages > 1

    generate_page_items(pages, current_page)
  end

  def full_page_range(current_page, total_pages)
    safe_join((1..total_pages).map do |page_number|
      page_item(page_number, current_page)
    end)
  end

  def generate_page_items(pages, current_page)
    safe_join(pages.map do |p|
      p == "..." ? disabled_page_ellipsis : page_item(p, current_page)
    end)
  end

  def disabled_page_ellipsis
    tag.li(tag.span("...", class: "page-link"), class: "page-item disabled")
  end

  def page_item(page, current_page)
    tag.li(class: "page-item #{'active' if page == current_page}") do
      if page == current_page
        tag.span(page, class: "page-link")
      else
        tag.a(page, href: url_for(page: page), class: "page-link")
      end
    end
  end
end
