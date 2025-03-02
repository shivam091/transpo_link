# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

class PaginationMetadata
  attr_reader :current_page, :per_page, :total_pages, :total_count,
              :next_page, :previous_page, :offset

  def initialize(current_page:, per_page:, total_pages:, total_count:, next_page:, previous_page:, offset:)
    @current_page = current_page
    @per_page = per_page
    @total_pages = total_pages
    @total_count = total_count
    @next_page = next_page
    @previous_page = previous_page
    @offset = offset
  end

  def first_page?
    current_page == 1
  end

  def last_page?
    current_page == total_pages
  end

  def needs_pagination?
    total_pages > 1
  end
end
