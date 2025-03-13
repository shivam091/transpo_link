# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/initializers/pretty_form_builder_spec.rb

require "spec_helper"

RSpec.describe PrettyFormBuilder, type: :helper do
  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :test_users, force: true do |t|
        t.string :reference_code
        t.string :name
        t.string :password
        t.string :email
        t.string :role
        t.date :joining_date
        t.integer :age
        t.text :bio
        t.boolean :is_active
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

  let!(:object) { TestUser.new(name: "Test", email: "test@example.com", role: "admin") }
  let!(:builder) { described_class.new(:test_user, object, self, {}) }

  describe "#text_field" do
    context "when :static option is not passed" do
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

    context "when :static option is passed" do
      it "adds the 'form-control-plaintext' class to text fields" do
        allow_any_instance_of(TestUser).to receive(:reference_code) { "ADM-00000001" }

        expected = <<~HTML
          <input readonly="readonly" disabled="disabled" class="form-control-plaintext" type="text" value="ADM-00000001" name="test_user[reference_code]" id="test_user_reference_code" />
        HTML
        output = builder.text_field(:reference_code, static: true)

        expect(output).to match_html(expected)
      end
    end
  end

  describe "#password_field" do
    it "adds the 'form-control' class to password fields" do
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

  describe "#number_field" do
    it "adds the 'form-control' class to number fields" do
      expected = <<~HTML
        <input class="form-control" type="number" name="test_user[age]" id="test_user_age" />
      HTML
      output = builder.number_field(:age)

      expect(output).to match_html(expected)
    end

    it "preserves existing classes and adds 'form-control'" do
      expected = <<~HTML
        <input class="custom-class form-control" type="number" name="test_user[age]" id="test_user_age" />
      HTML
      output = builder.number_field(:age, class: "custom-class")

      expect(output).to match_html(expected)
    end

    it "does not add duplicate classes" do
      expected = <<~HTML
        <input class="form-control custom-class" type="number" name="test_user[age]" id="test_user_age" />
      HTML
      output = builder.number_field(:age, class: "form-control custom-class")

      expect(output).to match_html(expected)
    end
  end

  describe "#date_field" do
    it "adds the 'form-control' class to date fields" do
      expected = <<~HTML
        <input class="form-control" type="date" name="test_user[joining_date]" id="test_user_joining_date" />
      HTML
      output = builder.date_field(:joining_date)

      expect(output).to match_html(expected)
    end

    it "preserves existing classes and adds 'form-control'" do
      expected = <<~HTML
        <input class="custom-class form-control" type="date" name="test_user[joining_date]" id="test_user_joining_date" />
      HTML
      output = builder.date_field(:joining_date, class: "custom-class")

      expect(output).to match_html(expected)
    end

    it "does not add duplicate classes" do
      expected = <<~HTML
        <input class="form-control custom-class" type="date" name="test_user[joining_date]" id="test_user_joining_date" />
      HTML
      output = builder.date_field(:joining_date, class: "form-control custom-class")

      expect(output).to match_html(expected)
    end
  end

  describe "#text_area" do
    it "adds the 'form-control' class to number fields" do
      expected = <<~HTML
        <textarea class="form-control" name="test_user[bio]" id="test_user_bio"></textarea>
      HTML
      output = builder.text_area(:bio)

      expect(output).to match_html(expected)
    end

    it "preserves existing classes and adds 'form-control'" do
      expected = <<~HTML
        <textarea class="custom-class form-control" name="test_user[bio]" id="test_user_bio"></textarea>
      HTML
      output = builder.text_area(:bio, class: "custom-class")

      expect(output).to match_html(expected)
    end

    it "does not add duplicate classes" do
      expected = <<~HTML
        <textarea class="form-control custom-class" name="test_user[bio]" id="test_user_bio"></textarea>
      HTML
      output = builder.text_area(:bio, class: "form-control custom-class")

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

  describe "#check_box" do
    it "adds the 'form-check-input' class to check box" do
      expected = <<~HTML
        <input name="test_user[is_active]" type="hidden" value="0" autocomplete="off" />
        <input class="form-check-input" type="checkbox" value="1" name="test_user[is_active]" id="test_user_is_active" />
      HTML
      output = builder.check_box(:is_active)

      expect(output).to match_html(expected)
    end

    it "preserves existing classes and adds 'form-check-input'" do
      expected = <<~HTML
        <input name="test_user[is_active]" type="hidden" value="0" autocomplete="off" />
        <input class="custom-class form-check-input" type="checkbox" value="1" name="test_user[is_active]" id="test_user_is_active" />
      HTML
      output = builder.check_box(:is_active, class: "custom-class")

      expect(output).to match_html(expected)
    end

    it "does not add duplicate classes" do
      expected = <<~HTML
        <input name="test_user[is_active]" type="hidden" value="0" autocomplete="off" />
        <input class="form-check-input custom-class" type="checkbox" value="1" name="test_user[is_active]" id="test_user_is_active" />
      HTML
      output = builder.check_box(:is_active, class: "form-check-input custom-class")

      expect(output).to match_html(expected)
    end
  end
end
