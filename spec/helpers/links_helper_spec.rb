# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/links_helper_spec.rb

require "spec_helper"

RSpec.describe LinksHelper, type: :helper do
  describe "#conditional_link_to" do
    let(:url) { "/test_path" }
    let(:html_options) { { class: "test-class" } }
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
end
