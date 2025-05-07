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
    it { is_expected.to have_db_column(:comment).of_type(:text) }
    it { is_expected.to have_db_column(:note).of_type(:text) }
    it { is_expected.to have_db_column(:created_at).of_type(:timestamptz).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:timestamptz).with_options(null: false) }

    it { is_expected.to have_db_index(:inventory_batch_id) }

    it { is_expected.to have_foreign_key(:inventory_batch_id).with_name(:fk_inventory_restocks_inventory_batch_id_on_inventory_batches).on_delete(:cascade) }

    it { is_expected.to have_check_constraint(:check_inventory_restocks_comment_length).with_expression("char_length(comment) <= 1000 AND char_length(comment) > 0") }
    it { is_expected.to have_check_constraint(:check_purchase_orders_note_length).with_expression("char_length(note) <= 1000") }
    it { is_expected.to have_check_constraint(:check_inventory_restocks_comment_presence).with_expression("comment IS NOT NULL AND comment <> ''::text") }
  end

  describe "associations" do
    it { is_expected.to belong_to(:inventory_batch).inverse_of(:restocks) }
  end

  describe "validations" do
    describe "#comment" do
      it { is_expected.to validate_presence_of(:comment) }
      it { is_expected.to validate_length_of(:comment).is_at_most(1000) }
    end

    describe "#note" do
      it { is_expected.to validate_length_of(:note).is_at_most(1000).allow_blank }
    end
  end
end
