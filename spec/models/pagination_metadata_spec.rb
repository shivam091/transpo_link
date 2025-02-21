# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/pagination_metadata_spec.rb

require "spec_helper"

RSpec.describe PaginationMetadata do
  let(:pagination) do
    described_class.new(
      current_page: 3,
      per_page: 10,
      total_pages: 5,
      total_count: 50,
      next_page: 4,
      previous_page: 2,
      offset: 20
    )
  end

  describe "#initialize" do
    it "assigns the correct attributes" do
      expect(pagination.current_page).to eq(3)
      expect(pagination.per_page).to eq(10)
      expect(pagination.total_pages).to eq(5)
      expect(pagination.total_count).to eq(50)
      expect(pagination.next_page).to eq(4)
      expect(pagination.previous_page).to eq(2)
      expect(pagination.offset).to eq(20)
    end
  end

  describe "#first_page?" do
    it "returns true if current page is 1" do
      first_page_pagination = described_class.new(
        current_page: 1,
        per_page: 10,
        total_pages: 5,
        total_count: 50,
        next_page: 2,
        previous_page: nil,
        offset: 0
      )
      expect(first_page_pagination.first_page?).to be_truthy
    end

    it "returns false if current page is not 1" do
      expect(pagination.first_page?).to be_falsy
    end
  end

  describe "#last_page?" do
    it "returns true if current page is the last page" do
      last_page_pagination = described_class.new(
        current_page: 5,
        per_page: 10,
        total_pages: 5,
        total_count: 50,
        next_page: nil,
        previous_page: 4,
        offset: 40
      )
      expect(last_page_pagination.last_page?).to be_truthy
    end

    it "returns false if current page is not the last page" do
      expect(pagination.last_page?).to be_falsy
    end
  end
end
