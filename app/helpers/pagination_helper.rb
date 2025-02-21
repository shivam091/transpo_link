# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module PaginationHelper
  def render_pagination(pagination_metadata)
    return "" if pagination_metadata.total_pages <= 1

    content = ActiveSupport::SafeBuffer.new

    content.safe_concat(tag.div(class: "d-flex justify-content-between align-items-center mb-1") do
      safe_concat(pagination_nav_tag(pagination_metadata))
      safe_concat(record_info_tag(pagination_metadata))
    end)

    content
  end

  private

  def record_info_tag(pagination_metadata)
    per_page = pagination_metadata.per_page || 10
    total_count = pagination_metadata.total_count || 0
    current_page = pagination_metadata.current_page || 1

    start_record = ((current_page - 1) * per_page) + 1
    end_record = [start_record + (per_page - 1), total_count].compact.min

    tag.p(
      t("pagination.record_info", start: start_record, end: end_record, total: total_count),
      class: "mb-0"
    )
  end

  def pagination_nav_tag(pagination_metadata)
    tag.nav(aria: {label: t("pagination.label")}) do
      tag.ul(class: "pagination mb-0") do
        safe_concat(previous_page_tag(pagination_metadata))
        safe_concat(page_number_tags(pagination_metadata))
        safe_concat(next_page_tag(pagination_metadata))
        safe_concat(page_select_tag(pagination_metadata))
      end
    end
  end

  def previous_page_tag(pagination_metadata)
    link_text = t("pagination.previous").html_safe

    tag.li(class: "page-item #{'disabled' unless pagination_metadata.previous_page}") do
      if pagination_metadata.previous_page
        tag.a(link_text, href: url_for(page: pagination_metadata.previous_page), class: "page-link")
      else
        tag.span(link_text, class: "page-link")
      end
    end
  end

  def next_page_tag(pagination_metadata)
    link_text = t("pagination.next").html_safe

    tag.li(class: "page-item #{'disabled' unless pagination_metadata.next_page}") do
      if pagination_metadata.next_page
        tag.a(link_text, href: url_for(page: pagination_metadata.next_page), class: "page-link")
      else
        tag.span(link_text, class: "page-link")
      end
    end
  end

  def page_number_tags(pagination_metadata)
    current_page = pagination_metadata.current_page
    total_pages = pagination_metadata.total_pages

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

  def page_select_tag(pagination_metadata)
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
end
