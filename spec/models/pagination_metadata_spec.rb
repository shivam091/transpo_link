# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/pagination_metadata_spec.rb

require "spec_helper"

RSpec.describe PaginationMetadata do
  let(:pagination_metadata) do
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
      expect(pagination_metadata.current_page).to eq(3)
      expect(pagination_metadata.per_page).to eq(10)
      expect(pagination_metadata.total_pages).to eq(5)
      expect(pagination_metadata.total_count).to eq(50)
      expect(pagination_metadata.next_page).to eq(4)
      expect(pagination_metadata.previous_page).to eq(2)
      expect(pagination_metadata.offset).to eq(20)
    end
  end

  describe "#first_page?" do
    let(:first_page_pagination_metadata) do
      described_class.new(
        current_page: 1,
        per_page: 10,
        total_pages: 5,
        total_count: 50,
        next_page: 2,
        previous_page: nil,
        offset: 0
      )
    end

    it "returns true if current page is 1" do
      expect(first_page_pagination_metadata.first_page?).to be_truthy
    end

    it "returns false if current page is not 1" do
      expect(pagination_metadata.first_page?).to be_falsy
    end
  end

  describe "#last_page?" do
    let(:last_page_pagination_metadata) do
      described_class.new(
        current_page: 5,
        per_page: 10,
        total_pages: 5,
        total_count: 50,
        next_page: nil,
        previous_page: 4,
        offset: 40
      )
    end

    it "returns true if current page is the last page" do
      expect(last_page_pagination_metadata.last_page?).to be_truthy
    end

    it "returns false if current page is not the last page" do
      expect(pagination_metadata.last_page?).to be_falsy
    end
  end

  describe "#needs_pagination?" do
    let(:single_page_pagination_metadata) do
      described_class.new(
        current_page: 1,
        per_page: 10,
        total_pages: 1,
        total_count: 5,
        next_page: nil,
        previous_page: nil,
        offset: 10
      )
    end

    it "returns true if total pages are greater than 1" do
      expect(pagination_metadata.needs_pagination?).to be_truthy
    end

    it "returns false if total pages are less than or equal to 1" do
      expect(single_page_pagination_metadata.needs_pagination?).to be_falsy
    end
  end
end
