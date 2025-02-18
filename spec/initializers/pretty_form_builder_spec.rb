# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/initializers/pretty_form_builder_spec.rb

require "spec_helper"

RSpec.describe PrettyFormBuilder, type: :helper do
  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :test_users, force: true do |t|
        t.string :name
        t.string :password
        t.string :email
        t.string :role
        t.boolean :is_active
        t.timestamps
      end
    end

    class TestUser < ApplicationRecord
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:test_users, if_exists: true)
    Object.send(:remove_const, :TestUser)
  end

  let(:object) { TestUser.new(name: "Test", email: "test@example.com", role: "admin") }
  let(:builder) { described_class.new(:test_user, object, self, {}) }

  describe "#text_field" do
    it "adds the 'form-control' class to text fields" do
      expected = <<~HTML
        <input class="form-control" type="text" value="Test" name="test_user[name]" id="test_user_name" />
      HTML
      output = builder.text_field(:name)

      expect(output).to match_html(expected)
    end

    it "preserves existing classes and adds 'form-control'" do
      expected = <<~HTML
        <input class="custom-class form-control" type="text" value="Test" name="test_user[name]" id="test_user_name" />
      HTML
      output = builder.text_field(:name, class: "custom-class")

      expect(output).to match_html(expected)
    end

    it "does not add duplicate classes" do
      expected = <<~HTML
        <input class="form-control custom-class" type="text" value="Test" name="test_user[name]" id="test_user_name" />
      HTML
      output = builder.text_field(:name, class: "form-control custom-class")

      expect(output).to match_html(expected)
    end
  end

  describe "#password_field" do
    it "adds the 'form-control' class to text fields" do
      expected = <<~HTML
        <input class="form-control" type="password" name="test_user[password]" id="test_user_password" />
      HTML
      output = builder.password_field(:password)

      expect(output).to match_html(expected)
    end

    it "preserves existing classes and adds 'form-control'" do
      expected = <<~HTML
        <input class="custom-class form-control" type="password" name="test_user[password]" id="test_user_password" />
      HTML
      output = builder.password_field(:password, class: "custom-class")

      expect(output).to match_html(expected)
    end

    it "does not add duplicate classes" do
      expected = <<~HTML
        <input class="form-control custom-class" type="password" name="test_user[password]" id="test_user_password" />
      HTML
      output = builder.password_field(:password, class: "form-control custom-class")

      expect(output).to match_html(expected)
    end
  end

  describe "#select" do
    it "adds the 'form-select' class to select fields" do
      expected = <<~HTML
        <select class="form-select" name="test_user[role]" id="test_user_role">
          <option selected value="admin">Admin</option>
          <option value="user">User</option>
        </select>
      HTML
      output = builder.select(:role, [["Admin", "admin"], ["User", "user"]])

      expect(output).to match_html(expected)
    end

    it "preserves existing classes and adds 'form-select'" do
      expected = <<~HTML
        <select class="custom-class form-select" name="test_user[role]" id="test_user_role">
          <option selected="selected" value="admin">Admin</option>
          <option value="user">User</option>
        </select>
      HTML
      output = builder.select(:role, [["Admin", "admin"], ["User", "user"]], {}, { class: "custom-class" })

      expect(output).to match_html(expected)
    end

    it "does not add duplicate classes" do
      expected = <<~HTML
        <select class="form-select custom-class" name="test_user[role]" id="test_user_role">
          <option selected="selected" value="admin">Admin</option>
          <option value="user">User</option>
        </select>
      HTML
      output = builder.select(:role, [["Admin", "admin"], ["User", "user"]], {}, { class: "form-select custom-class" })

      expect(output).to match_html(expected)
    end
  end

  describe "#radio_button" do
    it "adds the 'form-check-input' class to radio buttons" do
      expected = <<~HTML
        <input class="form-check-input" type="radio" value="false" name="test_user[is_active]" id="test_user_is_active_false" />
      HTML
      output = builder.radio_button(:is_active, false)

      expect(output).to match_html(expected)
    end

    it "preserves existing classes and adds 'form-check-input'" do
      expected = <<~HTML
        <input class="custom-class form-check-input" type="radio" value="false" name="test_user[is_active]" id="test_user_is_active_false" />
      HTML
      output = builder.radio_button(:is_active, false, class: "custom-class")

      expect(output).to match_html(expected)
    end

    it "does not add duplicate classes" do
      expected = <<~HTML
        <input class="form-check-input custom-class" type="radio" value="false" name="test_user[is_active]" id="test_user_is_active_false" />
      HTML
      output = builder.radio_button(:is_active, false, class: "form-check-input custom-class")

      expect(output).to match_html(expected)
    end
  end
end
