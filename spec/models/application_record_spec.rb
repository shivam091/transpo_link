# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/application_record_spec.rb

require "spec_helper"

RSpec.describe ApplicationRecord, type: :model do
  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :dummy_models, force: true do |t|
        t.string :email
        t.timestamps
      end
    end

    class DummyModel < ApplicationRecord
    end
  end

  after(:all) do
    connection.drop_table(:dummy_models, if_exists: true)
    Object.send(:remove_const, :DummyModel)
  end

  subject { DummyModel.new(email: "test@example.com") }

  describe ".[]" do
    it "returns the arel table attribute" do
      expect(DummyModel[:email].name).to eq("email")
    end
  end

  describe ".table" do
    it "returns the arel table" do
      expect(DummyModel.table.name).to eq("dummy_models")
    end
  end

  describe ".without_order" do
    let(:query_with_order) { DummyModel.order(:created_at) }
    let(:query_without_order) { query_with_order.without_order }

    it "removes ordering from the query" do
      expect(query_with_order.to_sql).to include("ORDER BY")
      expect(query_without_order.to_sql).to exclude("ORDER BY")
    end
  end

  describe ".none" do
    it "returns an empty relation" do
      expect(DummyModel.none).to be_empty
    end
  end

  describe ".scoped_table" do
    it "returns an aliased arel table" do
      expect(DummyModel.scoped_table.name).to eq("dummy_models")
    end
  end

  describe ".safe_find_or_create_by!" do
    let(:attributes) { {email: "test@example.com"} }

    context "when the record exists" do
      let!(:existing_user) { DummyModel.create!(attributes) }
      let!(:found_user) { DummyModel.safe_find_or_create_by!(attributes) }

      it "returns the existing record" do
        expect(found_user).to eq(existing_user)
      end
    end

    context "when the record does not exist" do
      let(:new_user) { DummyModel.safe_find_or_create_by!(attributes) }

      it "creates and returns the new record" do
        expect(new_user).to be_persisted
        expect(new_user.email).to eq("test@example.com")
      end
    end
  end

  describe ".safe_find_or_create_by" do
    let(:attributes) { {email: "test@example.com"} }

    context "when the record exists" do
      let!(:existing_user) { DummyModel.create!(attributes) }
      let!(:found_user) { DummyModel.safe_find_or_create_by(attributes) }

      it "returns the existing record" do
        expect(found_user).to eq(existing_user)
      end
    end

    context "when the record does not exist" do
      let(:new_user) { DummyModel.safe_find_or_create_by(attributes) }

      it "creates and returns the new record" do
        expect(new_user).to be_persisted
        expect(new_user.email).to eq("test@example.com")
      end
    end

    context "when a unique constraint is violated" do
      let(:found_user) { DummyModel.safe_find_or_create_by(attributes) }

      it "rescues from RecordNotUnique and returns the existing record" do
        DummyModel.create!(attributes)
        allow(DummyModel).to receive(:create).and_raise(ActiveRecord::RecordNotUnique)

        expect(found_user.email).to eq("test@example.com")
      end
    end
  end

  describe "#touch_self" do
    let(:user) { DummyModel.create!(email: "test@example.com") }
    let(:other_user) { DummyModel.create!(email: "other@example.com") }

    it "updates the updated_at timestamps of both objects" do
      user.update!(updated_at: 1.day.ago)
      other_user.update!(updated_at: 1.day.ago)

      expect {
        user.touch_self(other_user)
      }.to change { user.reload.updated_at }.and change { other_user.reload.updated_at }
    end
  end
end
