# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

require "spec_helper"

RSpec.describe Sanitizable do
  before(:all) do
    connection.create_table :sanitizable_models, force: true do |t|
      t.string :name
      t.string :email
      t.text :bio
      t.timestamps
    end

    class SanitizableModel < ApplicationRecord
      include Sanitizable

      sanitize_attributes :name
      sanitize_attributes :bio, allow_html: true
    end
  end

  after(:all) do
    connection.drop_table :sanitizable_models, if_exists: true
    Object.send(:remove_const, :SanitizableModel)
  end

  subject { SanitizableModel.new }

  it { expect(SanitizableModel).to respond_to(:sanitize_attributes) }

  it { is_expected.to sanitize_attribute(:name) }
  it { is_expected.to sanitize_attribute(:bio).allow_html }

  describe "#sanitize_attributes" do
    it "removes all HTML when allow_html is false" do
      subject.name = "<b>Jane Doe</b> <script>alert('XSS');</script>"

      subject.valid?

      expect(subject.name).to eq("Jane Doe alert('XSS');")
    end

    it "removes control characters from attributes" do
      subject.name = "Jane\u0000Doe\u0007"

      subject.valid?

      expect(subject.name).to eq("Jane Doe")
    end

    it "allows safe HTML when allow_html is true" do
      subject.bio = "<b>This is my bio.</b> <script>alert('XSS');</script>"

      subject.valid?

      expect(subject.bio).to eq("<b>This is my bio.</b>")
    end

    it "removes script, iframe, and other dangerous tags even when allow_html is true" do
      subject.bio = "<b>Safe</b> <iframe src='http://malicious.com'></iframe> <script>alert('XSS');</script>"

      subject.valid?

      expect(subject.bio).to eq("<b>Safe</b>")
    end

    it "does not alter attributes if there is no HTML" do
      subject.name, subject.bio = "Jane Doe", "This is a clean bio."

      subject.valid?

      expect(subject.name).to eq("Jane Doe")
      expect(subject.bio).to eq("This is a clean bio.")
    end

    it "handles nil values gracefully" do
      subject.name, subject.bio = nil, nil

      subject.valid?

      expect(subject.name).to be_nil
      expect(subject.bio).to be_nil
    end
  end
end
