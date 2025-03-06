# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/toggleable_spec.rb

require "spec_helper"

RSpec.describe Toggleable do
  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :toggleable_models, force: true do |t|
        t.boolean :is_active
        t.timestamps
      end
    end

    class ToggleableModel < ApplicationRecord
      include Toggleable
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:toggleable_models, if_exists: true)
    Object.send(:remove_const, :ToggleableModel)
  end

  let!(:inactive_record) { ToggleableModel.create!(is_active: false) }
  let!(:active_record) { ToggleableModel.create!(is_active: true) }

  describe "scopes" do
    it "returns active records" do
      expect(active_record).to be_one_of(ToggleableModel.active)
      expect(inactive_record).not_to be_one_of(ToggleableModel.active)
    end

    it "returns inactive records" do
      expect(inactive_record).to be_one_of(ToggleableModel.inactive)
      expect(active_record).not_to be_one_of(ToggleableModel.inactive)
    end
  end

  describe "#activate" do
    it "activates an inactive record" do
      expect { inactive_record.activate }.to change { inactive_record.reload.is_active }.from(false).to(true)
    end

    it "does not change if already active" do
      expect { active_record.activate }.to not_change { active_record.reload.is_active }
    end
  end

  describe "#deactivate" do
    it "deactivates an active record" do
      expect { active_record.deactivate }.to change { active_record.reload.is_active }.from(true).to(false)
    end

    it "does not change if already inactive" do
      expect { inactive_record.deactivate }.to not_change { inactive_record.reload.is_active }
    end
  end

  describe "callbacks" do
    it "runs before_activate callback" do
      called = false

      ToggleableModel.before_activate { called = true }

      inactive_record.activate
      expect(called).to be_truthy
    end


    it "runs after_deactivate callback" do
      called = false
      ToggleableModel.after_deactivate { called = true }

      active_record.deactivate
      expect(called).to be_truthy
    end

    it "runs around_activate callback" do
      execution_order = []

      ToggleableModel.around_activate do |record, block|
        execution_order << "before"
        block.call
        execution_order << "after"
      end

      inactive_record.activate
      expect(execution_order).to eq(["before", "after"])
    end
  end

  describe "class methods" do
    it "activates all records" do
      ToggleableModel.deactivate  # First ensure all are inactive
      expect { ToggleableModel.activate }.to change { ToggleableModel.active.count }.from(0).to(2)
    end

    it "deactivates all records" do
      ToggleableModel.activate  # First ensure all are active
      expect { ToggleableModel.deactivate }.to change { ToggleableModel.inactive.count }.from(0).to(2)
    end
  end
end
