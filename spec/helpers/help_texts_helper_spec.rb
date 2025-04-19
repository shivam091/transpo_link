# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/help_texts_helper_spec.rb

require "spec_helper"

RSpec.describe HelpTextsHelper, type: :helper do
  describe "#help_text" do
    context "when the help text is an empty string" do
      it "returns nil" do
        expect(helper.help_text("")).to be_nil
      end
    end

    context "when help text is nil" do
      it "returns nil" do
        expect(helper.help_text(nil)).to be_nil
      end
    end

    context "when tag is not specified" do
      it "defaults to :small tag" do
        expect(helper.help_text("This is a help message")).to eq('<small class="form-text text-muted">This is a help message</small>')
      end
    end

    context "when tag is within HTML_SAFE_TAGS" do
      it "returns help text wrapped in the specified tag" do
        expect(helper.help_text("This is a help message", tag: :div)).to eq('<div class="form-text text-muted">This is a help message</div>')
      end
    end

    context "when tag is not within HTML_SAFE_TAGS" do
      it "falls back to :span" do
        expect(helper.help_text("This is a help message", tag: :script)).to eq("<span class=\"form-text text-muted\">This is a help message</span>")
      end
    end

    context "when a block is given" do
      it "captures and returns help text inside the block wrapped in a :small tag" do
        expect(helper.help_text { "Block help text" }).to eq('<small class="form-text text-muted">Block help text</small>')
      end

      it "does not include empty content in the block" do
        expect(helper.help_text { "" }).to be_nil
      end

      it "does not include nil content in the block" do
        expect(helper.help_text { nil }).to be_nil
      end
    end

    context "when a block is given and specified tag is supported" do
      it "captures and returns help text inside the block wrapped in the specified tag" do
        expect(helper.help_text(tag: :div) { "Block help text with div" }).to eq('<div class="form-text text-muted">Block help text with div</div>')
      end

      it "returns nil if the block content is empty" do
        expect(helper.help_text(tag: :div) { "" }).to be_nil
      end
    end

    context "when HTML-safe help text is passed" do
      it "escapes HTML content to prevent XSS" do
        expect(helper.help_text("<script>alert('x')</script>")).to eq('<small class="form-text text-muted">&lt;script&gt;alert(&#39;x&#39;)&lt;/script&gt;</small>')
      end

      it "allows safe HTML input when marked as html_safe" do
        expect(helper.help_text("<strong>Bold</strong>".html_safe)).to eq('<small class="form-text text-muted"><strong>Bold</strong></small>')
      end
    end
  end
end
