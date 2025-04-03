# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

require "spec_helper"

RSpec.describe FormsHelper, type: :helper do
  describe "#form_errors" do
    let(:record) { double("Record") }

    context "when the record has errors" do
      before do
        allow(record).to receive(:errors) {
          double(
            any?: true,
            count: 2,
            full_messages: ["Email can't be blank", "Password is too short"]
          )
        }
      end

      let(:result) { helper.form_errors(record) }

      it "renders the error explanation div with error messages" do
        expect(result).to have_selector("div#error-explanation")
        expect(result).to have_selector("h6", text: "Whoops! There were some problems with your inputs. Please fix them before continuing:")
        expect(result).to have_selector("dd", text: "Email can't be blank")
        expect(result).to have_selector("dd", text: "Password is too short")
      end

      it "renders the error icon for each message" do
        expect(result.scan("icon-times").count).to eq(2)
      end
    end

    context "when the record has no errors" do
      it "returns nil" do
        allow(record).to receive(:errors) { double(any?: false) }

        expect(helper.form_errors(record)).to be_nil
      end
    end
  end

  describe "#help_text" do
    context "when given a string argument" do
      it "returns help text wrapped in a small tag with the correct class" do
        expect(helper.help_text("This is a help message")).to eq('<small class="form-text text-muted">This is a help message</small>')
      end
    end

    context "when given a different HTML tag as a parameter" do
      it "returns help text wrapped in the specified tag with the correct class" do
        expect(helper.help_text("This is a help message", :div)).to eq('<div class="form-text text-muted">This is a help message</div>')
      end
    end

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

    context "when a block is given" do
      it "captures and returns help text inside the block wrapped in a small tag" do
        expect(helper.help_text { "Block help text" }).to eq('<small class="form-text text-muted">Block help text</small>')
      end

      it "does not include empty content in the block" do
        expect(helper.help_text { "" }).to be_nil
      end

      it "does not include nil content in the block" do
        expect(helper.help_text { nil }).to be_nil
      end
    end

    context "when block is given and a tag is specified" do
      it "captures and returns help text inside the block wrapped in the specified tag" do
        expect(helper.help_text(:div) { "Block help text with div" }).to eq('<div class="form-text text-muted">Block help text with div</div>')
      end

      it "returns nil if the block content is empty" do
        expect(helper.help_text(:div) { "" }).to be_nil
      end
    end
  end
end
