# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/pagination_helper_spec.rb

require "spec_helper"

RSpec.describe PaginationHelper, type: :helper do
  let(:pagination_metadata) do
    PaginationMetadata.new(
      current_page: 3,
      per_page: 10,
      total_pages: 5,
      total_count: 50,
      next_page: 4,
      previous_page: 2,
      offset: 20
    )
  end

  let(:pagination_metadata_first_page) do
    PaginationMetadata.new(
      current_page: 1,
      per_page: 10,
      total_pages: 5,
      total_count: 50,
      next_page: 2,
      previous_page: nil,
      offset: 0
    )
  end

  let(:pagination_metadata_last_page) do
    PaginationMetadata.new(
      current_page: 5,
      per_page: 10,
      total_pages: 5,
      total_count: 50,
      next_page: nil,
      previous_page: 4,
      offset: 40
    )
  end

  before do
    allow(helper).to receive(:url_for) do |params|
      "/dummy_url?page=#{params[:page]}"
    end
  end

  describe "#render_pagination" do
    it "returns empty string if only one page exists" do
      expect(helper.render_pagination(
        PaginationMetadata.new(
          total_pages: 1,
          current_page: 1,
          per_page: 10,
          total_count: 10,
          next_page: nil,
          previous_page: nil,
          offset: 0)
        )
      ).to eq("")
    end

    it "renders pagination" do
      rendered_html = helper.render_pagination(pagination_metadata)

      expect(rendered_html).to include("<div class=\"pagination-container\">")
      expect(rendered_html).to include("<nav aria-label=\"Pagination\">")
      expect(rendered_html).to include("<p class=\"record-info\">")
    end
  end

  describe "#record_info" do
    it "renders record info correctly for middle page" do
      html = helper.send(:record_info, pagination_metadata)

      expect(html).to include("Displaying 21 to 30 of 50 in total")
    end

    it "renders correct info for first page" do
      html = helper.send(:record_info, pagination_metadata_first_page)

      expect(html).to include("Displaying 1 to 10 of 50 in total")
    end

    it "renders correct info for last page" do
      html = helper.send(:record_info, pagination_metadata_last_page)

      expect(html).to include("Displaying 41 to 50 of 50 in total")
    end

    it "renders zero entries when no records exist" do
      html = helper.send(:record_info, PaginationMetadata.new(current_page: 1, per_page: 10, total_pages: 1, total_count: 0, next_page: nil, previous_page: nil, offset: 0))

      expect(html).to include("Displaying 1 to 0 of 0 in total")
    end
  end

  describe "#pagination_nav" do
    it "renders pagination navigation correctly" do
      html = helper.send(:pagination_nav, pagination_metadata)

      expect(html).to include("<nav aria-label=\"Pagination\">")
      expect(html).to include("<ul class=\"pagination mb-0\">")
      expect(html).to include("page=2")
      expect(html).to include("page=4")
    end

    it "does not include previous page link if on first page" do
      html = helper.send(:pagination_nav, pagination_metadata_first_page)

      expect(html).to include("class=\"page-item disabled\"")
      expect(html).not_to include("page=0")
    end

    it "does not include next page link if on last page" do
      html = helper.send(:pagination_nav, pagination_metadata_last_page)

      expect(html).to include("class=\"page-item disabled\"")
      expect(html).not_to include("page=6")
    end
  end

  describe "#first_page_item" do
    it "renders first page link when not on first page" do
      html = helper.send(:first_page_item, pagination_metadata)

      expect(html).to include("page=1")
      expect(html).not_to include("class=\"page-item disabled\"")
    end

    it "disables first page link when on first page" do
      html = helper.send(:first_page_item, pagination_metadata_first_page)

      expect(html).to include("class=\"page-item disabled\"")
      expect(html).to include("<a role=\"link\" class=\"page-link\" aria-label=\"First\">&laquo;</a>")
    end
  end

  describe "#last_page_item" do
    it "renders last page link when not on last page" do
      html = helper.send(:last_page_item, pagination_metadata)

      expect(html).to include("page=5")
      expect(html).not_to include("class=\"page-item disabled\"")
    end

    it "disables last page link when on last page" do
      html = helper.send(:last_page_item, pagination_metadata_last_page)

      expect(html).to include("class=\"page-item disabled\"")
      expect(html).to include("<a role=\"link\" class=\"page-link\" aria-label=\"Last\">&raquo;</a>")
    end
  end

  describe "#previous_page_item" do
    it "renders previous page link when available" do
      html = helper.send(:previous_page_item, pagination_metadata)

      expect(html).to include("page=2")
    end

    it "disables previous page link when unavailable" do
      html = helper.send(:previous_page_item, pagination_metadata_first_page)

      expect(html).to include("class=\"page-item disabled\"")
      expect(html).to include("<a role=\"link\" class=\"page-link\" aria-label=\"Previous\">&lsaquo;</a>")
    end
  end

  describe "#next_page_item" do
    it "renders next page link when available" do
      html = helper.send(:next_page_item, pagination_metadata)

      expect(html).to include("page=4")
    end

    it "disables next page link when unavailable" do
      html = helper.send(:next_page_item, pagination_metadata_last_page)

      expect(html).to include("class=\"page-item disabled\"")
      expect(html).to include("<a role=\"link\" class=\"page-link\" aria-label=\"Next\">&rsaquo;</a>")
    end
  end

  describe "#page_number_items" do
    it "renders correct page numbers for small pagination" do
      html = helper.send(:page_number_items, PaginationMetadata.new(current_page: 2, total_pages: 3, per_page: 10, total_count: 30, next_page: 3, previous_page: 1, offset: 10))

      expect(html).to include("page=1")
      expect(html).to include("<a role=\"link\" class=\"page-link\" aria-current=\"page\">2</a>")
      expect(html).to include("page=3")
    end

    it "renders ellipsis when total pages exceed 8" do
      html = helper.send(:page_number_items, PaginationMetadata.new(current_page: 5, total_pages: 10, per_page: 10, total_count: 100, next_page: 6, previous_page: 4, offset: 40))

      expect(html).to include("&hellip;")
    end
  end

  describe "#full_page_range" do
    it "renders all pages when total pages are small" do
      html = helper.send(:full_page_range, 1, 5)

      (2..5).each { |page| expect(html).to include("page=#{page}") }
    end
  end

  describe "#generate_page_items" do
    it "renders page items with ellipsis correctly" do
      pages = [1, "...", 5]
      html = helper.send(:generate_page_items, pages, 3)

      expect(html).to include("...")
      expect(html).to include("page=1")
      expect(html).to include("page=5")
    end
  end

  describe "#disabled_page_ellipsis" do
    it "renders a disabled page item for ellipsis" do
      html = helper.send(:disabled_page_ellipsis)

      expect(html).to include("class=\"page-item disabled\"")
      expect(html).to include("<a role=\"link\" class=\"page-link\">&hellip;</a></li>")
    end
  end

  describe "#page_item" do
    it "renders an active page item for the current page" do
      html = helper.send(:page_item, 3, 3)

      expect(html).to include("class=\"page-item active\"")
      expect(html).to include("<a role=\"link\" class=\"page-link\" aria-current=\"page\">3</a>")
    end

    it "renders a clickable page item for other pages" do
      html = helper.send(:page_item, 2, 3)

      expect(html).to include("page=2")
      expect(html).to include("class=\"page-item \"")
    end
  end

  describe "#page_select_item" do
    it "renders a select dropdown with all pages" do
      html = helper.send(:page_select_item, pagination_metadata)

      (1..5).each do |page|
        expect(html).to include("page=#{page}")
      end
      expect(html).to include("<select name=\"page\"")
    end

    it "marks the current page as selected" do
      html = helper.send(:page_select_item, pagination_metadata)

      expect(html).to include("<option value=\"/dummy_url?page=3\" selected=\"selected\">")
    end
  end

  describe "#p_t" do
    before do
      I18n.backend.store_translations(:en, {
        pagination: {
          label: "Page Navigation",
          first: "First",
          last: "Last",
          record_info: "Showing %{start} to %{end} of %{total} entries"
        }
      })
    end

    it "translates keys within the pagination scope" do
      expect(helper.send(:p_t, "first")).to eq("First")
      expect(helper.send(:p_t, "last")).to eq("Last")
    end

    it "interpolates variables in translation" do
      translation = helper.send(:p_t, "record_info", start: 1, end: 10, total: 100)
      expect(translation).to eq("Showing 1 to 10 of 100 entries")
    end

    it "allows overriding the default scope" do
      I18n.backend.store_translations(:en, {custom_scope: {test_key: "Custom Scope Value"}})
      expect(helper.send(:p_t, "test_key", scope: "custom_scope")).to eq("Custom Scope Value")
    end
  end
end
