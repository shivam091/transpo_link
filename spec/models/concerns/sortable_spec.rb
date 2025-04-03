# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/sortable_spec.rb

require "spec_helper"

RSpec.describe Sortable do
  before(:all) do
    connection.create_table :sortable_models, force: true do |t|
      t.timestamps
    end

    class SortableModel < ApplicationRecord
      include Sortable
    end
  end

  after(:all) do
    connection.drop_table :sortable_models, if_exists: true
    Object.send(:remove_const, :SortableModel)
  end

  let!(:record1) { SortableModel.create(id: 1, created_at: 2.days.ago, updated_at: 2.days.ago) }
  let!(:record2) { SortableModel.create(id: 2, created_at: 1.day.ago, updated_at: 1.day.ago) }
  let!(:record3) { SortableModel.create(id: 3, created_at: Time.current, updated_at: Time.current) }

  describe "scopes" do
    describe ".order_id_asc" do
      it "orders by id ascending" do
        expect(SortableModel.order_id_asc.pluck(:id)).to eq([1, 2, 3])
      end
    end

    describe ".order_id_desc" do
      it "orders by id descending" do
        expect(SortableModel.order_id_desc.pluck(:id)).to eq([3, 2, 1])
      end
    end

    describe ".order_created_asc" do
      it "orders by created_at ascending" do
        expect(SortableModel.order_created_asc.pluck(:created_at)).to eq([record1.created_at, record2.created_at, record3.created_at])
      end
    end

    describe ".order_created_desc" do
      it "orders by created_at descending" do
        expect(SortableModel.order_created_desc.pluck(:created_at)).to eq([record3.created_at, record2.created_at, record1.created_at])
      end
    end

    describe ".order_updated_asc" do
      it "orders by updated_at ascending" do
        expect(SortableModel.order_updated_asc.pluck(:updated_at)).to eq([record1.updated_at, record2.updated_at, record3.updated_at])
      end
    end

    describe ".order_updated_desc" do
      it "orders by updated_at descending" do
        expect(SortableModel.order_updated_desc.pluck(:updated_at)).to eq([record3.updated_at, record2.updated_at, record1.updated_at])
      end
    end
  end

  describe ".order_by" do
    it "orders by id ascending" do
      expect(SortableModel.order_by(:id_asc).pluck(:id)).to eq([1, 2, 3])
    end

    it "orders by id descending" do
      expect(SortableModel.order_by(:id_desc).pluck(:id)).to eq([3, 2, 1])
    end

    it "orders by created_at ascending" do
      expect(SortableModel.order_by(:created_asc).pluck(:created_at)).to eq([record1.created_at, record2.created_at, record3.created_at])
      expect(SortableModel.order_by(:created_at_asc).pluck(:created_at)).to eq([record1.created_at, record2.created_at, record3.created_at])
    end

    it "orders by created_at descending" do
      expect(SortableModel.order_by(:created_desc).pluck(:created_at)).to eq([record3.created_at, record2.created_at, record1.created_at])
      expect(SortableModel.order_by(:created_at_desc).pluck(:created_at)).to eq([record3.created_at, record2.created_at, record1.created_at])
    end

    it "orders by updated_at ascending" do
      expect(SortableModel.order_by(:updated_asc).pluck(:updated_at)).to eq([record1.updated_at, record2.updated_at, record3.updated_at])
      expect(SortableModel.order_by(:updated_at_asc).pluck(:updated_at)).to eq([record1.updated_at, record2.updated_at, record3.updated_at])
    end

    it "orders by updated_at descending" do
      expect(SortableModel.order_by(:updated_desc).pluck(:updated_at)).to eq([record3.updated_at, record2.updated_at, record1.updated_at])
      expect(SortableModel.order_by(:updated_at_desc).pluck(:updated_at)).to eq([record3.updated_at, record2.updated_at, record1.updated_at])
    end

    it "returns all records when given an unknown method" do
      expect(SortableModel.order_by(:unknown).count).to eq(SortableModel.count)
    end
  end
end
