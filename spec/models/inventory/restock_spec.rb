# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/inventory/restock_spec.rb

require "spec_helper"

RSpec.describe Inventory::Restock, type: :model do
  subject(:inventory_restock) { build(:inventory_restock) }

  describe "valid factory" do
    it { is_expected.to have_a_valid_factory(:inventory_restock) }
  end

  describe "attributes, indexes, foreign keys, and check constraints" do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:inventory_batch_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:quantity).of_type(:decimal).with_options(precision: 12, scale: 2) }
    it { is_expected.to have_db_column(:unit_id).of_type(:uuid).with_options(null: false) }
    it { is_expected.to have_db_column(:comment).of_type(:text) }
    it { is_expected.to have_db_column(:note).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:unit_id) }
    it { is_expected.to have_db_index(:inventory_batch_id) }

    it { is_expected.to have_foreign_key(:unit_id).with_name(:fk_inventory_restocks_unit_id_on_units).on_delete(:restrict) }
    it { is_expected.to have_foreign_key(:inventory_batch_id).with_name(:fk_inventory_restocks_inventory_batch_id_on_inventory_batches).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_inventory_restocks_comment_length).with_expression("char_length(comment) <= 1000 AND char_length(comment) > 0") }
    it { is_expected.to have_check_constraint(:check_inventory_restocks_note_length).with_expression("char_length(note) <= 1000") }
    it { is_expected.to have_check_constraint(:check_inventory_restocks_comment_presence).with_expression("comment IS NOT NULL AND comment <> ''::text") }
    it { is_expected.to have_check_constraint(:check_inventory_restocks_quantity_positive).with_expression("quantity > 0.0") }
    it { is_expected.to have_check_constraint(:check_inventory_restocks_quantity_presence).with_expression("quantity IS NOT NULL") }
  end

  describe "included modules" do
    it { is_expected.to include_module(Sanitizable) }
    it { is_expected.to include_module(NullifyIfBlank) }
    it { is_expected.to include_module(ScaleEnforcer) }
  end

  describe "scaled attributes" do
    it { is_expected.to apply_scale_to(:quantity) }
  end

  describe "nullified attributes" do
    it { is_expected.to nullify_if_blank(:note) }
  end

  describe "sanitized attributes" do
    it { is_expected.to sanitize_attribute(:comment) }
    it { is_expected.to sanitize_attribute(:note) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:inventory_batch).inverse_of(:restocks) }
    it { is_expected.to belong_to(:unit).inverse_of(:restocks) }
  end

  describe "validations" do
    describe "#quantity" do
      it { is_expected.to validate_presence_of(:quantity) }

      context "when quantity is invalid" do
        let(:inventory_restock) { build(:inventory_restock, quantity: "abcd") }

        it "is invalid" do
          inventory_restock.validate

          expect(inventory_restock.errors[:quantity]).to include("must be greater than 0.0")
        end
      end

      context "when quantity <= 0.0" do
        let(:inventory_restock) { build(:inventory_restock, quantity: 0.0) }

        it "is invalid" do
          inventory_restock.validate

          expect(inventory_restock.errors[:quantity]).to include("must be greater than 0.0")
        end
      end

      context "when quantity > 0.0" do
        let(:inventory_restock) { build(:inventory_restock, quantity: 1.0) }

        it "is valid" do
          inventory_restock.validate

          expect(inventory_restock.errors[:quantity]).to be_empty
        end
      end
    end

    describe "#unit_id" do
      it { is_expected.to validate_presence_of(:unit_id) }
    end

    describe "#comment" do
      it { is_expected.to validate_presence_of(:comment) }
      it { is_expected.to validate_length_of(:comment).is_at_most(1000) }
    end

    describe "#note" do
      it { is_expected.to validate_length_of(:note).is_at_most(1000).allow_blank }
    end
  end
end
