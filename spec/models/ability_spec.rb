# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/models/ability_spec.rb

RSpec.describe Ability do
  let(:role) { create(:manager_role) }
  let(:user) { create(:manager, role:) }
  let(:ability) { described_class.new(user) }

  let(:module) { create(:module, label_key: "orders") }
  let(:action) { create(:action, label_key: "create") }

  let!(:permission) { create(:permission, module:, action:) }
  let!(:role_permission) { create(:role_permission, role:, permission:, is_allowed: true) }

  before { Rails.cache.clear }

  describe "#can?" do
    it "caches the result to avoid redundant checks" do
      allow(Rails.cache).to receive(:fetch) {
        {
          ["orders", "create"] => true,
          ["orders", "delete"] => false
        }
      }

      ability.can?("orders", "create")
      ability.can?("orders", "create")

      expect(Rails.cache).to have_received(:fetch).once
    end

    context "when permission is explicitly allowed" do
      it "returns true if the user has permission" do
        expect(ability.can?("orders", "create")).to be_truthy
      end

      it "returns true for alias action (new => create)" do
        stub_const("#{described_class}::ACTION_ALIASES", {"new" => "create"})

        expect(ability.can?("orders", "new")).to be_truthy
      end
    end

    context "when permission is explicitly denied" do
      before do
        permission = create(:permission, action: create(:action, label_key: "update"), module:)
        create(:role_permission, role:, permission:, is_allowed: false)
      end

      it "returns false even if permission exists but denied" do
        expect(ability.can?("orders", "update")).to be_falsy
      end
    end

    context "when no permission exists at all" do
      it "returns false when no permission exists for given module and action" do
        expect(ability.can?("inventory", "update")).to be_falsy
      end
    end
  end

  describe "#authorize!" do
    context "when permission is granted" do
      it "does not raise error" do
        expect { ability.authorize!("orders", "create") }.not_to raise_error
      end
    end

    context "when permission is denied" do
      before do
        permission = create(:permission, action: create(:action, label_key: "update"), module:)
        create(:role_permission, role:, permission:, is_allowed: false)
      end

      it "raises AccessDeniedError" do
        expect {
          ability.authorize!("orders", "update")
        }.to raise_error(AccessDeniedError, "Access denied to module: orders, action: update")
      end
    end

    context "when permission is not defined" do
      it "raises AccessDeniedError" do
        expect {
          ability.authorize!("shipments", "delete")
        }.to raise_error(AccessDeniedError, "Access denied to module: shipments, action: delete")
      end
    end
  end
end
