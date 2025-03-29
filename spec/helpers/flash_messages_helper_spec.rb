# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/flash_messages_helper_spec.rb

require "spec_helper"

RSpec.describe FlashMessagesHelper, type: :helper do
  describe "#flash_messages" do
    before { allow(helper).to receive(:flash) { flash_messages } }

    context "when flash messages are present" do
      let!(:flash_messages) { {notice: "Success!", alert: "Error occurred!", warning: "Be careful!", info: "Just so you know."} }
      let(:result) { helper.flash_messages }

      it "returns the correct HTML for each flash type" do
        expect(result).to include("alert-success")
        expect(result).to include("Success!")
        expect(result).to include("face-smile")

        expect(result).to include("alert-danger")
        expect(result).to include("Error occurred!")
        expect(result).to include("face-frown")

        expect(result).to include("alert-warning")
        expect(result).to include("Be careful!")
        expect(result).to include("exclamation-triangle")

        expect(result).to include("alert-info")
        expect(result).to include("Just so you know.")
        expect(result).to include("info-circle")
      end
    end

    context "when flash messages are empty" do
      let!(:flash_messages) { {} }

      it "returns an empty string" do
        expect(helper.flash_messages).to eq("")
      end
    end

    context "when flash message type is not in FLASH_TYPES" do
      let!(:flash_messages) { {unknown: "This should not be displayed."} }

      it "does not render unknown flash types" do
        expect(helper.flash_messages).to exclude("This should not be displayed.")
      end
    end
  end

  describe "#build_flash_message" do
    let(:result) { helper.send(:build_flash_message, :notice, "Success!") }

    it "generates the correct HTML for a given message type" do
      expect(result).to include("alert-success")
      expect(result).to include("face-smile")
      expect(result).to include("Success!")
      expect(result).to include("btn-close")
    end
  end
end
