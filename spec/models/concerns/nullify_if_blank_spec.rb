# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/nullify_if_blank_spec.rb

require "spec_helper"

RSpec.describe NullifyIfBlank do
  before(:all) do
    connection.create_table :nullify_if_blank_models, force: true do |t|
      t.string :name
      t.string :email
      t.timestamps
    end

    class NullifyIfBlankModel < ApplicationRecord
      include NullifyIfBlank

      nullify_if_blank :name, :email
    end
  end

  after(:all) do
    connection.drop_table :nullify_if_blank_models, if_exists: true
    Object.send(:remove_const, :NullifyIfBlankModel)
  end

  subject { NullifyIfBlankModel.new }

  it { expect(NullifyIfBlankModel).to respond_to(:nullify_if_blank) }

  it { is_expected.to nullify_if_blank(:name) }
  it { is_expected.to nullify_if_blank(:email) }

  describe "callbacks" do
    it { expect(NullifyIfBlankModel).to have_callback(:before, :validation, :nullify_blank_attributes) }
  end

  describe "#nullify_blank_attributes" do
    it "nullifies attributes that are blank before validation" do
      subject.name, subject.email = "", "  "
      subject.valid?

      expect(subject.name).to be_nil
      expect(subject.email).to be_nil
    end

    it "does not nullify attributes that are not blank" do
      subject.name, subject.email = "John Doe", "john@example.com"
      subject.valid?

      expect(subject.name).to eq("John Doe")
      expect(subject.email).to eq("john@example.com")
    end
  end
end
