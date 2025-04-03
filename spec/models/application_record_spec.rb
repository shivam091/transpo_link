# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/application_record_spec.rb

require "spec_helper"

RSpec.describe ApplicationRecord, type: :model do
  before(:all) do
    connection.create_table :emails, force: true do |t|
      t.string :email
      t.timestamps
    end

    class Email < ApplicationRecord
    end
  end

  after(:all) do
    connection.drop_table :emails, if_exists: true
    Object.send(:remove_const, :Email)
  end

  subject { Email.new(email: "test@example.com") }

  describe ".[]" do
    it "returns the arel table attribute" do
      expect(Email[:email].name).to eq("email")
    end
  end

  describe ".table" do
    it "returns the arel table" do
      expect(Email.table.name).to eq("emails")
    end
  end

  describe ".without_order" do
    let(:query_with_order) { Email.order(:created_at) }
    let(:query_without_order) { query_with_order.without_order }

    it "removes ordering from the query" do
      expect(query_with_order.to_sql).to include("ORDER BY")
      expect(query_without_order.to_sql).to exclude("ORDER BY")
    end
  end

  describe ".none" do
    it "returns an empty relation" do
      expect(Email.none).to be_empty
    end
  end

  describe ".scoped_table" do
    it "returns an aliased arel table" do
      expect(Email.scoped_table.name).to eq("emails")
    end
  end

  describe ".safe_find_or_create_by!" do
    let(:attributes) { {email: "test@example.com"} }

    context "when the record exists" do
      let!(:existing_email) { Email.create!(attributes) }
      let!(:found_email) { Email.safe_find_or_create_by!(attributes) }

      it "returns the existing record" do
        expect(found_email).to eq(existing_email)
      end
    end

    context "when the record does not exist" do
      let(:new_email) { Email.safe_find_or_create_by!(attributes) }

      it "creates and returns the new record" do
        expect(new_email).to be_persisted
        expect(new_email.email).to eq("test@example.com")
      end
    end
  end

  describe ".safe_find_or_create_by" do
    let(:attributes) { {email: "test@example.com"} }

    context "when the record exists" do
      let!(:existing_email) { Email.create!(attributes) }
      let!(:found_email) { Email.safe_find_or_create_by(attributes) }

      it "returns the existing record" do
        expect(found_email).to eq(existing_email)
      end
    end

    context "when the record does not exist" do
      let(:new_email) { Email.safe_find_or_create_by(attributes) }

      it "creates and returns the new record" do
        expect(new_email).to be_persisted
        expect(new_email.email).to eq("test@example.com")
      end
    end

    context "when a unique constraint is violated" do
      let(:found_email) { Email.safe_find_or_create_by(attributes) }

      it "creates the dummy model avoiding race conditions" do
        expect(Email).to receive(:find_by).and_return(nil, found_email) # Don't change syntax

        allow(Email).to receive(:create).and_raise(ActiveRecord::RecordNotUnique)

        expect(Email.safe_find_or_create_by(attributes)).to eq(found_email)
      end
    end
  end

  describe "#touch_self" do
    let!(:email) { Email.create!(email: "test@example.com") }
    let!(:other_email) { Email.create!(email: "other@example.com") }

    it "updates the updated_at timestamps of both objects" do
      email.update!(updated_at: 1.day.ago)
      other_email.update!(updated_at: 1.day.ago)

      expect {
        email.touch_self(other_email)
      }.to change { email.reload.updated_at }.and change { other_email.reload.updated_at }
    end
  end
end
