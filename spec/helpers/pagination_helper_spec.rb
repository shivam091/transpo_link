# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/pagination_helper_spec.rb

require "spec_helper"

RSpec.describe PaginationHelper, type: :helper do
  let(:pagination_data) do
    {
      current_page: 3,
      per_page: 10,
      total_pages: 5,
      total_count: 50,
      next_page: 4,
      previous_page: 2,
      offset: 20
    }
  end

  let(:pagination_data_first_page) do
    {
      current_page: 1,
      per_page: 10,
      total_pages: 5,
      total_count: 50,
      next_page: 2,
      previous_page: nil,
      offset: 0
    }
  end

  let(:pagination_data_last_page) do
    {
      current_page: 5,
      per_page: 10,
      total_pages: 5,
      total_count: 50,
      next_page: nil,
      previous_page: 4,
      offset: 40
    }
  end

  before do
    allow(helper).to receive(:url_for) do |params|
      "/dummy_url?page=#{params[:page]}"
    end
  end

  describe "#render_pagination" do
    it "returns empty string if only one page exists" do
      expect(helper.render_pagination({total_pages: 1})).to eq("")
    end

    it "renders pagination" do
      rendered_html = helper.render_pagination(pagination_data)
      expect(rendered_html).to include("<nav aria-label=\"Pagination\">")
      expect(rendered_html).to include("<p class=\"mb-0\">")
    end
  end

  describe "#record_info_tag" do
    it "renders record info correctly for middle page" do
      html = helper.send(:record_info_tag, pagination_data)
      expect(html).to include("Showing 21 to 30 of 50 entries")
    end

    it "renders correct info for first page" do
      html = helper.send(:record_info_tag, pagination_data_first_page)
      expect(html).to include("Showing 1 to 10 of 50 entries")
    end

    it "renders correct info for last page" do
      html = helper.send(:record_info_tag, pagination_data_last_page)
      expect(html).to include("Showing 41 to 50 of 50 entries")
    end

    it "renders zero entries when no records exist" do
      html = helper.send(:record_info_tag, {current_page: 1, per_page: 10, total_entries: 0})
      expect(html).to include("Showing 1 to 0 of 0 entries")
    end
  end

  describe "#pagination_nav_tag" do
    it "renders pagination navigation correctly" do
      html = helper.send(:pagination_nav_tag, pagination_data)
      expect(html).to include("<nav aria-label=\"Pagination\">")
      expect(html).to include("<ul class=\"pagination mb-0\">")
      expect(html).to include("page=2")
      expect(html).to include("page=4")
    end

    it "does not include previous page link if on first page" do
      html = helper.send(:pagination_nav_tag, pagination_data_first_page)
      expect(html).to include("class=\"page-item disabled\"")
      expect(html).not_to include("page=0")
    end

    it "does not include next page link if on last page" do
      html = helper.send(:pagination_nav_tag, pagination_data_last_page)
      expect(html).to include("class=\"page-item disabled\"")
      expect(html).not_to include("page=6")
    end
  end

  describe "#previous_page_tag" do
    it "renders previous page link when available" do
      html = helper.send(:previous_page_tag, pagination_data)
      expect(html).to include("page=2")
    end

    it "disables previous page link when unavailable" do
      html = helper.send(:previous_page_tag, pagination_data_first_page)
      expect(html).to include("class=\"page-item disabled\"")
      expect(html).to include("<span class=\"page-link\">&laquo;&nbsp;Previous</span>")
    end
  end

  describe "#next_page_tag" do
    it "renders next page link when available" do
      html = helper.send(:next_page_tag, pagination_data)
      expect(html).to include("page=4")
    end

    it "disables next page link when unavailable" do
      html = helper.send(:next_page_tag, pagination_data_last_page)
      expect(html).to include("class=\"page-item disabled\"")
      expect(html).to include("<span class=\"page-link\">Next&nbsp;&raquo;</span>")
    end
  end

  describe "#page_number_tags" do
    it "renders correct page numbers for small pagination" do
      html = helper.send(:page_number_tags, {current_page: 2, total_pages: 3})
      expect(html).to include("page=1")
      expect(html).to include("<span class=\"page-link\">2</span>")
      expect(html).to include("page=3")
    end

    it "renders ellipsis when total pages exceed 8" do
      html = helper.send(:page_number_tags, {current_page: 5, total_pages: 10})
      expect(html).to include("...")
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
      expect(html).to include("<span class=\"page-link\">...</span>")
    end
  end

  describe "#page_item" do
    it "renders an active page item for the current page" do
      html = helper.send(:page_item, 3, 3)
      expect(html).to include("class=\"page-item active\"")
      expect(html).to include("<span class=\"page-link\">3</span>")
    end

    it "renders a clickable page item for other pages" do
      html = helper.send(:page_item, 2, 3)
      expect(html).to include("page=2")
      expect(html).to include("class=\"page-item \"")
    end
  end
end
