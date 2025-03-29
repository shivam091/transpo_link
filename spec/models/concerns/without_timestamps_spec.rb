# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/without_timestamps_spec.rb

require "spec_helper"

RSpec.describe WithoutTimestamps do
  # Dynamically create a virtual table before running tests
  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :test_models, force: true do |t|
        t.string :name
        t.timestamps  # Include created_at and updated_at
      end
    end

    # Define a virtual model that uses the virtual table
    class TestModel < ActiveRecord::Base
      include WithoutTimestamps
    end
  end

  # Clean up the virtual table after tests are done
  after(:all) do
    connection.drop_table(:test_models, if_exists: true)
    Object.send(:remove_const, :TestModel)  # Remove TestModel constant
  end

  let!(:record) { TestModel.create(name: "Initial Name") }

  describe ".without_timestamps" do
    let!(:original_updated_at) { record.updated_at }

    it "does not update timestamps inside the block" do
      sleep(1)  # Ensure there's a noticeable time gap

      TestModel.without_timestamps do
        record.update(name: "Updated Name")
      end

      expect(record.reload.updated_at).to eq(original_updated_at)
    end

    it "restores timestamp behavior after the block" do
      TestModel.without_timestamps do
        record.update(name: "Temporary Update")
      end

      sleep(1)

      record.update(name: "Final Update")

      expect(record.reload.updated_at).to be > original_updated_at
    end

    it "logs errors and restores timestamp behavior after an exception" do
      expect(Rails.logger).to receive(:error).with(/Intentional Error/)

      expect {
        TestModel.without_timestamps do
          raise StandardError, "Intentional Error"
        end
      }.to raise_error(StandardError, "Intentional Error")

      expect(ActiveRecord::Base.record_timestamps).to be_truthy
    end
  end
end
