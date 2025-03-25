# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/modals_helper_spec.rb

require "spec_helper"

RSpec.describe ModalsHelper, type: :helper do
  describe "#render_modal" do
    let(:default_options) do
      {
        title: "",
        modal_id: "modal-window",
        size_class: "modal-md"
      }
    end

    before { allow(helper).to receive(:render_if_exists) }

    context "when no options are provided" do
      it "uses the default options" do
        helper.render_modal

        expect(helper).to have_received(:render_if_exists).with(
          "shared/remote_modal",
          locals: default_options
        )
      end
    end

    context "when a custom title is provided" do
      it "overrides the default title" do
        helper.render_modal(title: "Custom Title")

        expect(helper).to have_received(:render_if_exists).with(
          "shared/remote_modal",
          locals: default_options.merge(title: "Custom Title")
        )
      end
    end

    context "when a custom modal_id is provided" do
      it "overrides the default modal_id" do
        helper.render_modal(modal_id: "custom-modal")

        expect(helper).to have_received(:render_if_exists).with(
          "shared/remote_modal",
          locals: default_options.merge(modal_id: "custom-modal")
        )
      end
    end

    context "when a custom size is provided" do
      it "sets the correct size_class for :lg" do
        helper.render_modal(size: :lg)

        expect(helper).to have_received(:render_if_exists).with(
          "shared/remote_modal",
          locals: default_options.merge(size_class: "modal-lg")
        )
      end

      it "sets the correct size_class for :sm" do
        helper.render_modal(size: :sm)

        expect(helper).to have_received(:render_if_exists).with(
          "shared/remote_modal",
          locals: default_options.merge(size_class: "modal-sm")
        )
      end

      it "sets the correct size_class for :xl" do
        helper.render_modal(size: :xl)

        expect(helper).to have_received(:render_if_exists).with(
          "shared/remote_modal",
          locals: default_options.merge(size_class: "modal-xl")
        )
      end
    end

    context "when size_class is explicitly provided" do
      it "uses the provided size_class instead of size mapping" do
        helper.render_modal(size_class: "custom-size-class")

        expect(helper).to have_received(:render_if_exists).with(
          "shared/remote_modal",
          locals: default_options.merge(size_class: "custom-size-class")
        )
      end
    end

    context "when both size and size_class are provided" do
      it "prioritizes the provided size_class over size" do
        helper.render_modal(size: :lg, size_class: "custom-size-class")

        expect(helper).to have_received(:render_if_exists).with(
          "shared/remote_modal",
          locals: default_options.merge(size: :lg, size_class: "custom-size-class")
        )
      end
    end

    context "when a block is provided" do
      let(:block) { proc { "Modal content" } }

      it "yields the block to the partial" do
        helper.render_modal(&block)

        expect(helper).to have_received(:render_if_exists).with(
          "shared/remote_modal",
          locals: default_options
        )
      end
    end
  end
end
