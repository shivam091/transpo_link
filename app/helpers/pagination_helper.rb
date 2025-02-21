# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module PaginationHelper
  def render_pagination(pagination_metadata)
    return "" if pagination_metadata.total_pages <= 1

    content = ActiveSupport::SafeBuffer.new

    content.safe_concat(tag.div(class: "pagination-container") do
      safe_concat(pagination_nav(pagination_metadata))
      safe_concat(record_info(pagination_metadata))
    end)

    content
  end

  private

  def record_info(pagination_metadata)
    per_page = pagination_metadata.per_page || 10
    total_count = pagination_metadata.total_count || 0
    current_page = pagination_metadata.current_page || 1

    start_record = ((current_page - 1) * per_page) + 1
    end_record = [start_record + (per_page - 1), total_count].compact.min

    tag.span(
      p_t("record_info", start: start_record, end: end_record, total: total_count),
      class: "record-info"
    )
  end

  def pagination_nav(pagination_metadata)
    tag.nav(aria: {label: p_t("aria_labels.nav")}) do
      tag.ul(class: "pagination mb-0") do
        safe_concat(first_page_item(pagination_metadata))
        safe_concat(previous_page_item(pagination_metadata))
        safe_concat(page_number_items(pagination_metadata))
        safe_concat(next_page_item(pagination_metadata))
        safe_concat(last_page_item(pagination_metadata))
        safe_concat(page_select_item(pagination_metadata))
      end
    end
  end

  def first_page_item(pagination_metadata)
    link_text = p_t("first").html_safe
    options = {class: "page-link", aria: {label: p_t("aria_labels.first")}}

    tag.li(class: "page-item #{'disabled' unless pagination_metadata.current_page > 1}") do
      if pagination_metadata.current_page > 1
        tag.a(link_text, href: url_for(page: 1), **options)
      else
        tag.a(link_text, role: "link", **options)
      end
    end
  end

  def last_page_item(pagination_metadata)
    link_text = p_t("last").html_safe
    options = {class: "page-link", aria: {label: p_t("aria_labels.last")}}

    tag.li(class: "page-item #{'disabled' unless pagination_metadata.current_page < pagination_metadata.total_pages}") do
      if pagination_metadata.current_page < pagination_metadata.total_pages
        tag.a(link_text, href: url_for(page: pagination_metadata.total_pages), **options)
      else
        tag.a(link_text, role: "link", **options)
      end
    end
  end

  def previous_page_item(pagination_metadata)
    link_text = p_t("previous").html_safe
    options = {class: "page-link", aria: {label: p_t("aria_labels.previous")}}

    tag.li(class: "page-item #{'disabled' unless pagination_metadata.previous_page}") do
      if pagination_metadata.previous_page
        tag.a(link_text, href: url_for(page: pagination_metadata.previous_page), **options)
      else
        tag.a(link_text, role: "link", **options)
      end
    end
  end

  def next_page_item(pagination_metadata)
    link_text = p_t("next").html_safe
    options = {class: "page-link", aria: {label: p_t("aria_labels.next")}}

    tag.li(class: "page-item #{'disabled' unless pagination_metadata.next_page}") do
      if pagination_metadata.next_page
        tag.a(link_text, href: url_for(page: pagination_metadata.next_page), **options)
      else
        tag.a(link_text, role: "link", **options)
      end
    end
  end

  def page_number_items(pagination_metadata)
    current_page = pagination_metadata.current_page
    total_pages = pagination_metadata.total_pages

    return full_page_range(current_page, total_pages) if total_pages < 8

    range = 2
    pages = [1]
    pages << :gap if (current_page - range) > 2
    ((current_page - range)..(current_page + range)).each { |p| pages << p if (p > 1) && (p < total_pages) }
    pages << :gap if (current_page + range) < (total_pages - 1)
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
      p == :gap ? disabled_page_ellipsis : page_item(p, current_page)
    end)
  end

  def disabled_page_ellipsis
    tag.li(tag.a(p_t("gap").html_safe, role: "link", class: "page-link"), class: "page-item disabled")
  end

  def page_item(page, current_page)
    tag.li(class: "page-item #{'active' if page == current_page}") do
      if page == current_page
        tag.a(page, role: "link", class: "page-link", aria: {current: "page"})
      else
        tag.a(page, href: url_for(page: page), class: "page-link")
      end
    end
  end

  def page_select_item(pagination_metadata)
    total_pages = pagination_metadata.total_pages
    current_page = pagination_metadata.current_page

    tag.li(class: "page-item") do
      tag.select(name: "page", class: "page-select form-select", onchange: "Turbo.visit(this.value)") do
        safe_join((1..total_pages).map do |page|
          tag.option(page, value: url_for(page: page), selected: (page == current_page ? "selected" : nil))
        end)
      end
    end
  end

  def p_t(key, options = {})
    options.reverse_merge!(scope: "pagination")
    t(key, **options)
  end
end
