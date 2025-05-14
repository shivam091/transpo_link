# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/links_helper_spec.rb

require "spec_helper"

RSpec.describe LinksHelper, type: :helper do
  describe "#conditional_link_to" do
    let(:url) { "/test_path" }
    let(:html_options) { {class: "test-class"} }
    let(:block_content) { "Click here" }

    context "when condition is true" do
      let(:result) { helper.conditional_link_to(true, url, html_options) { block_content } }

      it "returns a link with the block content" do
        expect(result).to eq(link_to(url, html_options) { block_content })
      end
    end

    context "when condition is false" do
      let(:result) { helper.conditional_link_to(false, url, html_options) { block_content } }

      it "returns only the block content" do
        expect(result).to eq(block_content)
      end
    end

    context "when condition is nil" do
      let(:result) { helper.conditional_link_to(nil, url, html_options) { block_content } }

      it "returns only the block content" do
        expect(result).to eq(block_content)
      end
    end

    context "when html_options are empty" do
      let(:result) { helper.conditional_link_to(true, url, {}) { block_content } }

      it "returns a link without additional attributes" do
        expect(result).to eq(link_to(url) { block_content })
      end
    end

    context "when block returns HTML content" do
      let(:result) { helper.conditional_link_to(true, url, html_options) { "<strong>Click here</strong>".html_safe } }

      it "returns proper HTML output" do
        expect(result).to have_selector("a", class: "test-class")
        expect(result).to have_selector("strong", text: "Click here")
      end
    end
  end

  describe "#link_to_product" do
    let(:product) { build_stubbed(:product, name: "Test product") }

    it "returns a link to the product" do
      expect(helper.link_to_product(product)).to eq(
        helper.link_to("Test product", product_path(product))
      )
    end
  end

  describe "#link_to_warehouse" do
    let(:warehouse) { build_stubbed(:warehouse, name: "Test warehouse") }

    it "returns a link to the warehouse" do
      expect(helper.link_to_warehouse(warehouse)).to eq(
        helper.link_to("Test warehouse", warehouse_path(warehouse))
      )
    end
  end

  describe "#link_to_user" do
    let(:user) { build_stubbed(:buyer) }

    it "returns a link to the user" do
      allow(user).to receive(:full_name) { "User Name" }

      expect(helper.link_to_user(user)).to eq(
        helper.link_to("User Name", user_path(user))
      )
    end
  end

  describe "#link_to_model" do
    let(:product) { build_stubbed(:product, name: "Test product") }

    context "with a default parameters" do
      it "generates a link using default name and path" do
        expect(helper.link_to_model(product)).to eq(
          helper.link_to("Test product", product_path(product))
        )
      end

      it "applies additional HTML options" do
        result = helper.link_to_model(product, class: "text-danger", data: {confirm: "Are you sure?"})

        expect(result).to eq(
          helper.link_to("Test product", product_path(product), class: "text-danger", data: {confirm: "Are you sure?"})
        )
      end
    end

    context "with a custom label method" do
      it "uses the specified text method for display text" do
        allow(product).to receive(:reference_code) { "PRD-123" }

        expect(helper.link_to_model(product, label_method: :reference_code)).to eq(
          helper.link_to("PRD-123", product_path(product))
        )
      end
    end

    context "with a custom label method as a callable" do
      it "uses the callable label method for display text" do
        custom_label = ->(m) { "Custom Label: #{m.name}" }

        expect(helper.link_to_model(product, label_method: custom_label)).to eq(
          helper.link_to("Custom Label: Test product", product_path(product))
        )
      end
    end

    context "with a custom path method" do
      it "uses the provided path_method" do
        expect(helper.link_to_model(product, path_method: :edit_product_path)).to eq(
          helper.link_to("Test product", edit_product_path(product))
        )
      end
    end

    context "with a namespace" do
      before do
        allow(helper).to receive(:url_helpers) do
          double(admin_product_path: "/admin/products/#{product.id}")
        end
      end

      it "uses namespaced path method when namespace is given" do
        expect(helper.link_to_model(product, namespace: :admin)).to eq(
          helper.link_to("Test product", "/admin/products/#{product.id}")
        )
      end
    end

    context "with a callable path_method" do
      it "uses the callable path method" do
        custom_path = ->(m) { Rails.application.routes.url_helpers.edit_product_path(m) }

        expect(helper.link_to_model(product, path_method: custom_path)).to eq(
          helper.link_to("Test product", edit_product_path(product))
        )
      end
    end

    context "when model is nil" do
      it "returns nil" do
        expect(helper.link_to_model(nil)).to be_nil
      end
    end
  end

  describe "#link_to_polymorphic" do
    let(:product) { build_stubbed(:product, name: "Test product") }

    it "renders a polymorphic link with default label method" do
      expect(helper.link_to_polymorphic(product)).to eq(
        helper.link_to("Test product", product_path(product))
      )
    end

    it "supports additional html options" do
      expect(
        helper.link_to_polymorphic(product, class: "text-info")
      ).to eq(helper.link_to("Test product", product_path(product), class: "text-info"))
    end

    it "supports namespace and custom label_method" do
      allow(product).to receive(:reference_code) { "PRD-001" }
      allow(helper).to receive(:polymorphic_path).with([:admin, product]) { "/admin/products/1" }

      expect(
        helper.link_to_polymorphic(product, label_method: :reference_code, namespace: :admin)
      ).to eq(helper.link_to("PRD-001", "/admin/products/1"))
    end

    it "supports callable label method for display text" do
      custom_label = ->(m) { "Custom Label: #{m.name}" }

      expect(helper.link_to_polymorphic(product, label_method: custom_label)).to eq(
        helper.link_to("Custom Label: Test product", product_path(product))
      )
    end

    it "returns nil when model is nil" do
      expect(helper.link_to_polymorphic(nil)).to be_nil
    end
  end
end
