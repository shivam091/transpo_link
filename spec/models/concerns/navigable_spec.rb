# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/navigable_spec.rb

require "spec_helper"

RSpec.describe Navigable do
  before(:all) do
    connection.create_table :navigable_models, force: true do |t|
      t.string  :name
      t.integer :position
      t.timestamps
    end

    class NavigableModel < ApplicationRecord
      include Navigable

      self.ordering_column = :position
      self.ordering_direction = :asc
    end
  end

  after(:all) do
    connection.drop_table(:navigable_models, if_exists: true)
    Object.send(:remove_const, :NavigableModel)
  end

  let!(:first_record)  { NavigableModel.create!(name: "First", position: 1) }
  let!(:second_record) { NavigableModel.create!(name: "Second", position: 2) }
  let!(:third_record)  { NavigableModel.create!(name: "Third", position: 3) }

  describe "default scope" do
    it "orders records by position in ascending order" do
      expect(NavigableModel.all).to eq([first_record, second_record, third_record])
    end
  end

  describe "#next_record" do
    it "returns the next record in the sequence" do
      expect(first_record.next_record).to eq(second_record)
      expect(second_record.next_record).to eq(third_record)
    end

    it "returns nil if no next record exists" do
      expect(third_record.next_record).to be_nil
    end
  end

  describe "#previous_record" do
    it "returns the previous record in the sequence" do
      expect(third_record.previous_record).to eq(second_record)
      expect(second_record.previous_record).to eq(first_record)
    end

    it "returns nil if no previous record exists" do
      expect(first_record.previous_record).to be_nil
    end
  end

  describe "class methods" do
    describe ".default_navigable_scope" do
      it "returns the default scope order" do
        expect(NavigableModel.default_navigable_scope.to_sql).to include("ORDER BY \"navigable_models\".\"position\" ASC")
      end
    end
  end

  describe "handling missing ordering column values" do
    let!(:record_without_position) { NavigableModel.create!(name: "No Position", position: nil) }

    it "skips records with nil ordering column when finding next record" do
      expect(second_record.next_record).to eq(third_record) # Should not return record_without_position
    end

    it "skips records with nil ordering column when finding previous record" do
      expect(third_record.previous_record).to eq(second_record) # Should not return record_without_position
    end
  end

  describe "changing ordering dynamically" do
    before do
      NavigableModel.ordering_direction = :desc
    end

    after do
      NavigableModel.ordering_direction = :asc # Reset to default
    end

    it "returns records in descending order when ordering direction is reversed" do
      expect(NavigableModel.default_navigable_scope.to_sql).to include("ORDER BY \"navigable_models\".\"position\" DESC")
    end

    it "returns records in descending order" do
      expect(third_record.next_record).to eq(second_record)
      expect(second_record.next_record).to eq(first_record)
    end

    it "returns records in descending order for previous_record" do
      expect(first_record.previous_record).to eq(second_record)
      expect(second_record.previous_record).to eq(third_record)
    end
  end

  describe "handling unscoped queries" do
    before do
      NavigableModel.unscoped { NavigableModel.create!(name: "Unscoped Record", position: 5) }
    end

    it "does not break navigation when unscoped" do
      expect(second_record.next_record).to eq(third_record) # Should not include unscoped records
    end
  end

  describe "ensuring navigation consistency" do
    it "ensures next_record of a record is the previous_record of the next record" do
      expect(second_record.previous_record).to eq(first_record)
      expect(second_record).to eq(first_record.next_record)
    end

    it "ensures previous_record of a record is the next_record of the previous record" do
      expect(third_record.previous_record).to eq(second_record)
      expect(third_record).to eq(second_record.next_record)
    end
  end

  describe "handling unordered records" do
    let(:unsequenced_record) { NavigableModel.create!(name: "Random Order", position: 10) }

    it "respects ordering and does not break navigation" do
      expect(third_record.next_record).to be_nil
      expect(second_record.next_record).to eq(third_record)
    end
  end

  describe "handling nil or missing records" do
    let(:missing_record) { NavigableModel.new(name: "Missing") }

    it "returns nil if calling next_record on a non-existing record" do
      expect(missing_record.next_record).to be_nil
    end

    it "returns nil if calling previous_record on a non-existing record" do
      expect(missing_record.previous_record).to be_nil
    end
  end
end
