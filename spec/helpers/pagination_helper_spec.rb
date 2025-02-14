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

    it "renders pagination navigation" do
      rendered_html = helper.render_pagination(pagination_data)
      expect(rendered_html).to include("<nav aria-label=\"Pagination\">")
      expect(rendered_html).to include("<ul class=\"pagination justify-content-center\">")
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
      expect(html).to include("<span class=\"page-link\">Previous</span>")
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
      expect(html).to include("<span class=\"page-link\">Next</span>")
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
end
