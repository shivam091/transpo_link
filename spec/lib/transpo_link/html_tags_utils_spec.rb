# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/html_tags_utils_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::HtmlTagsUtils do
  include described_class

  describe "#resolve_html_tag" do
    context "when the input is nil" do
      it "returns nil" do
        expect(resolve_html_tag(nil)).to be_nil
      end
    end

    context "when the input is a valid safe tag" do
      it "returns :span for 'span'" do
        expect(resolve_html_tag("span")).to eq(:span)
      end

      it "returns :a for 'a'" do
        expect(resolve_html_tag("a")).to eq(:a)
      end

      it "returns :div for symbol input" do
        expect(resolve_html_tag(:div)).to eq(:div)
      end

      it "is case insensitive" do
        expect(resolve_html_tag("BUTTON")).to eq(:button)
      end

      it "strips whitespace from the tag" do
        expect(resolve_html_tag("  small  ")).to eq(:small)
      end
    end

    context "when the input is not in the safe list" do
      it "returns :span for unsafe tag 'script'" do
        expect(resolve_html_tag("script")).to eq(:span)
      end

      it "returns :span for random string" do
        expect(resolve_html_tag("foobar")).to eq(:span)
      end

      it "returns :span for empty string" do
        expect(resolve_html_tag("")).to eq(:span)
      end
    end
  end
end
