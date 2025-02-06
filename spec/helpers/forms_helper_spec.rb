# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

require "spec_helper"

RSpec.describe FormsHelper, type: :helper do
  describe "#form_errors" do
    let(:record) { double("Record") }

    context "when the record has errors" do
      before do
        allow(record).to receive(:errors).and_return(
          double(
            any?: true,
            count: 2,
            full_messages: ["Email can't be blank", "Password is too short"]
          )
        )
      end

      it "renders the error explanation div with error messages" do
        result = helper.form_errors(record)

        expect(result).to have_selector("div#error-explanation")
        expect(result).to have_selector("h6", text: "Whoops! There were some problems with your inputs. Please fix them before continuing:")
        expect(result).to have_selector("dd", text: "Email can't be blank")
        expect(result).to have_selector("dd", text: "Password is too short")
      end

      it "renders the error icon for each message" do
        result = helper.form_errors(record)

        expect(result.scan("icon-cancel").count).to eq(2)
      end
    end

    context "when the record has no errors" do
      before do
        allow(record).to receive(:errors).and_return(
          double(any?: false)
        )
      end

      it "returns nil" do
        expect(helper.form_errors(record)).to be_nil
      end
    end
  end
end
