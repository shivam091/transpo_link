# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/concerns/case_sensitivity_spec.rb

require "spec_helper"

RSpec.describe CaseSensitivity do
  before(:all) do
    connection.create_table :case_sensitive_models, force: true do |t|
      t.string :name
      t.string :email
      t.timestamps
    end

    class CaseSensitiveModel < ApplicationRecord
      include CaseSensitivity
    end
  end

  after(:all) do
    connection.drop_table :case_sensitive_models, if_exists: true
    Object.send(:remove_const, :CaseSensitiveModel)
  end

  let!(:record1) { CaseSensitiveModel.create!(name: "Alice", email: "alice@example.com") }
  let!(:record2) { CaseSensitiveModel.create!(name: "Bob", email: "BOB@example.com") }
  let!(:record3) { CaseSensitiveModel.create!(name: "Charlie", email: "charlie@Example.com") }

  describe ".iwhere" do
    context "when querying with single values" do
      it "finds records case-insensitively by name" do
        expect(record1).to be_one_of(CaseSensitiveModel.iwhere(name: "alice"))
        expect(record1).to be_one_of(CaseSensitiveModel.iwhere(name: "ALICE"))
        expect(record1).to be_one_of(CaseSensitiveModel.iwhere(name: "Alice"))
      end

      it "finds records case-insensitively by email" do
        expect(record2).to be_one_of(CaseSensitiveModel.iwhere(email: "bob@example.com"))
        expect(record2).to be_one_of(CaseSensitiveModel.iwhere(email: "BOB@EXAMPLE.COM"))
      end

      it "returns no records if no match found" do
        expect(CaseSensitiveModel.iwhere(name: "David")).to be_empty
      end
    end

    context "when querying with arrays" do
      it "finds records case-insensitively with multiple names" do
        expect(CaseSensitiveModel.iwhere(name: ["alice", "CHARLIE"])).to include(record1, record3)
      end

      it "finds records case-insensitively with multiple emails" do
        expect(CaseSensitiveModel.iwhere(email: ["bob@example.com", "CHARLIE@example.COM"])).to include(record2, record3)
      end

      it "returns no records if no matches found in array" do
        expect(CaseSensitiveModel.iwhere(name: ["david", "john"])).to be_empty
      end
    end

    context "when querying multiple fields at once" do
      it "finds records matching all conditions" do
        expect(record1).to be_one_of(CaseSensitiveModel.iwhere(name: "Alice", email: "ALICE@example.COM"))
      end

      it "returns no records if one condition does not match" do
        expect(CaseSensitiveModel.iwhere(name: "Alice", email: "wrong@example.com")).to be_empty
      end
    end
  end
end
