# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

RSpec.shared_examples "a unique product in collection validator" do
  let(:parent_record) { create(parent_factory) }

  let(:product) { create(:product) }
  let(:unit) { create(:unit) }

  subject(:child_record) { build_child(parent => parent_record, product:, unit:) }

  before do
    # Ensure the association is preloaded as required by the validator
    parent_record.public_send(child_collection).to_a
  end

  context "when child record is marked for destruction" do
    it "does not add validation error" do
      child_record.mark_for_destruction
      child_record.valid?

      expect(child_record.errors[:product_id]).to be_empty
    end
  end

  context "when parent record is not present" do
    before { child_record.public_send("#{parent}=", nil) }

    it "does not add validation error" do
      child_record.valid?

      expect(child_record.errors[:product_id]).to be_empty
    end
  end

  context "when collection is not loaded" do
    it "skips validation if not preloaded" do
      allow(child_record.public_send(parent).public_send(child_collection)).to receive(:loaded?) { false }

      child_record.valid?

      expect(child_record.errors[:product_id]).to be_empty
    end
  end

  context "when it is the only child record with the product" do
    it "is valid" do
      expect(child_record).to be_valid
    end
  end

  context "when there are two child records with the same product" do
    let!(:existing_child_record) { create_child(parent => parent_record, product:, unit:) }

    it "adds a validation error to the second child record" do
      expect(child_record).to be_invalid
      expect(child_record.errors[:product_id]).to include(/has already been added/)
    end
  end

  context "when duplicate child record is marked for destruction" do
    let!(:existing_child_record) do
      create_child(parent => parent_record, product:, unit:).tap(&:mark_for_destruction)
    end

    it "is valid since other child record is being destroyed" do
      expect(child_record).to be_valid
    end
  end

  context "when current child record is the first duplicate" do
    let!(:child_record) { create_child(parent => parent_record, product:, unit:) }
    let!(:other_child_record) { build_child(parent => parent_record, product:, unit:) }

    it "does not add error on the first matching child record" do
      parent_record.public_send(child_collection) << child_record << other_child_record

      expect(child_record).to be_valid
      expect(other_child_record).to be_invalid
      expect(other_child_record.errors[:product_id]).to include(/has already been added/)
    end
  end

  private

  def build_child(attributes = {})
    build(child_factory, {parent => parent_record, product:, unit:}.merge(attributes))
  end

  def create_child(attributes = {})
    create(child_factory, {parent => parent_record, product:, unit:}.merge(attributes))
  end
end
