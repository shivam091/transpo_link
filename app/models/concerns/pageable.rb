# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module Pageable
  extend ActiveSupport::Concern

  class_methods do
    def estimated_count
      Rails.cache.fetch("#{name}/estimated_count", expires_in: 10.minutes) do
        query = "SELECT reltuples::bigint FROM pg_class WHERE oid = '#{table_name}'::regclass"
        result = connection.execute(query).first["reltuples"].to_i
        result.positive? ? result : count
      end
    end

    def total_pages(per_page)
      estimated_count.positive? ? (estimated_count.to_f / per_page).ceil : 1
    end

    def paginate(page = 1, per_page = 20)
      page = page.to_i.positive? ? page.to_i : 1
      per_page = per_page.to_i.positive? ? per_page.to_i : 20
      total_pages = total_pages(per_page)
      offset = (page - 1) * per_page

      paginated_records = offset(offset).limit(per_page)
      pagination_data = {
        current_page: page,
        per_page: per_page,
        total_pages: total_pages,
        total_count: estimated_count,
        next_page: (page < total_pages) ? (page + 1) : nil,
        previous_page: (page > 1) ? (page - 1) : nil,
        offset: offset
      }

      [paginated_records, pagination_data]
    end
  end
end
