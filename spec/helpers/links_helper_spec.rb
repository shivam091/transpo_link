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
      it "returns a link with the block content" do
        result = helper.conditional_link_to(true, url, html_options) { block_content }
        expect(result).to eq(link_to(url, html_options) { block_content })
      end
    end

    context "when condition is false" do
      it "returns only the block content" do
        result = helper.conditional_link_to(false, url, html_options) { block_content }
        expect(result).to eq(block_content)
      end
    end

    context "when condition is nil" do
      it "returns only the block content" do
        result = helper.conditional_link_to(nil, url, html_options) { block_content }
        expect(result).to eq(block_content)
      end
    end

    context "when html_options are empty" do
      it "returns a link without additional attributes" do
        result = helper.conditional_link_to(true, url, {}) { block_content }
        expect(result).to eq(link_to(url) { block_content })
      end
    end

    context "when block returns HTML content" do
      it "returns proper HTML output" do
        result = helper.conditional_link_to(true, url, html_options) { "<strong>Click here</strong>".html_safe }
        expect(result).to include("<a")
        expect(result).to include("test-class")
        expect(result).to include("<strong>Click here</strong>")
      end
    end
  end
end
