# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/pageable_spec.rb

require "spec_helper"

RSpec.describe Pageable do
  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :pageable_models, force: true do |t|
        t.string :name
        t.string :email
        t.timestamps
      end
    end

    class PageableModel < ApplicationRecord
      include Pageable
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:pageable_models, if_exists: true)
    Object.send(:remove_const, :PageableModel)
  end

  describe ".estimated_count" do
    before do
      allow(PageableModel.connection).to receive(:execute) { [{"reltuples" => 50}] }
      allow(PageableModel).to receive(:count) { 50 }

      Rails.cache.clear
    end

    it "returns the estimated count from database" do
      expect(PageableModel.estimated_count).to eq(50)
    end

    it "caches the estimated count result" do
      PageableModel.estimated_count
      allow(PageableModel.connection).to receive(:execute) { [{"reltuples" => 50}] }

      expect(PageableModel.estimated_count).to eq(50)
    end

    it "falls back to exact count if estimated count is zero" do
      allow(PageableModel.connection).to receive(:execute) { [{"reltuples" => 0}] }
      allow(PageableModel).to receive(:count) { 20 }

      expect(PageableModel.estimated_count).to eq(20)
    end
  end

  describe ".total_pages" do
    it "returns the correct total pages" do
      allow(PageableModel).to receive(:estimated_count) { 50 }

      expect(PageableModel.total_pages(10)).to eq(5)
    end

    it "returns 1 if estimated count is 0" do
      allow(PageableModel).to receive(:estimated_count) { 0 }

      expect(PageableModel.total_pages(10)).to eq(1)
    end
  end

  describe ".paginate" do
    let!(:records) do
      50.times do |n|
        PageableModel.create(name: "Test #{n}", email: "test#{n}@example.com")
      end
    end

    it "returns paginated records and pagination data" do
      paginated_records, pagination_metadata = PageableModel.paginate(page: 2, per_page: 10)

      expect(paginated_records.size).to eq(10)
      expect(pagination_metadata).to be_a(PaginationMetadata)
    end

    it "returns first page if page is invalid" do
      paginated_records, pagination_metadata = PageableModel.paginate(page: 0, per_page: 10)

      expect(pagination_metadata.current_page).to eq(1)
      expect(paginated_records.size).to eq(10)
    end

    it "handles cases where total count is less than per_page" do
      allow(PageableModel).to receive(:estimated_count) { 8 }
      paginated_records, pagination_metadata = PageableModel.paginate(page: 1, per_page: 10)

      expect(pagination_metadata.total_pages).to eq(1)
      expect(pagination_metadata.total_count).to eq(8)
      expect(pagination_metadata.next_page).to be_nil
    end
  end
end
