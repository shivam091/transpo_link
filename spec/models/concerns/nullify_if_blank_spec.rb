# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/nullify_if_blank_spec.rb

require "spec_helper"

RSpec.describe NullifyIfBlank do
  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :nullify_if_blank_models, force: true do |t|
        t.string :name
        t.string :email
        t.timestamps
      end
    end

    class NullifyIfBlankModel < ApplicationRecord
      include NullifyIfBlank

      nullify_if_blank :name, :email
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:nullify_if_blank_models, if_exists: true)
    Object.send(:remove_const, :NullifyIfBlankModel)
  end

  subject { NullifyIfBlankModel.new }

  it { is_expected.to nullify_if_blank(:name) }
  it { is_expected.to nullify_if_blank(:email) }

  describe "#nullify_blank_attributes" do
    it "nullifies attributes that are blank before validation" do
      record = NullifyIfBlankModel.new(name: "", email: "  ")
      record.valid?
      expect(record.name).to be_nil
      expect(record.email).to be_nil
    end

    it "does not nullify attributes that are not blank" do
      record = NullifyIfBlankModel.new(name: "John Doe", email: "john@example.com")
      record.valid?
      expect(record.name).to eq("John Doe")
      expect(record.email).to eq("john@example.com")
    end
  end
end
