# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/initializers/pretty_form_helper_spec.rb

require "spec_helper"

RSpec.describe PrettyFormHelper, type: :helper do
  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :test_users, force: true do |t|
        t.string :name
        t.timestamps
      end
    end

    class TestUser < ApplicationRecord
    end
  end

  after(:all) do
    connection.drop_table(:test_users, if_exists: true)
    Object.send(:remove_const, :TestUser)
  end

  let!(:object) { TestUser.new(name: "Test") }

  describe "#pretty_form_for" do
    it "renders form tag" do
      expected = <<~HTML
        <form class="new_test_user" id="new_test_user" action="/test" accept-charset="UTF-8" method="post"></form>
      HTML
      output = pretty_form_for(object, url: "/test") {}

      expect(output).to match_html(expected)
    end
  end

  describe "#pretty_form_with" do
    it "renders form tag" do
      expected = <<~HTML
        <form action="/test" accept-charset="UTF-8" method="post"></form>
      HTML
      output = pretty_form_with(model: object, url: "/test") {}

      expect(output).to match_html(expected)
    end
  end
end
