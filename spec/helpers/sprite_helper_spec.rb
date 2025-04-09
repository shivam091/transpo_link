# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/sprite_helper_spec.rb

require "spec_helper"

RSpec.describe SpriteHelper, type: :helper do
  let(:fake_image_url) { "sprite.svg" }

  before { allow(helper).to receive(:image_url) { fake_image_url } }

  describe "#sprite_icon" do
    context "when used in navigation bar" do
      it "renders the home icon with custom class and id" do
        html = helper.sprite_icon("home", class: "text-gray-500", id: "home-icon")

        expect(html).to have_selector("svg#home-icon.icon.icon-home.text-gray-500[height='24px'][width='24px']")
        expect(html).to have_selector("use[href$='sprite.svg#home']", visible: false)
      end
    end

    context "when used inside a button" do
      it "renders the plus icon with Stimulus data attributes" do
        html = helper.sprite_icon("plus", class: "text-white ml-2", data: {action: "click->modal#open"})

        expect(html).to have_selector("svg.icon.icon-plus.text-white.ml-2[data-action='click->modal#open']")
        expect(html).to have_selector("use[href$='sprite.svg#plus']", visible: false)
      end
    end

    context "when used as an alert icon with overridden size" do
      it "renders a larger alert icon" do
        html = helper.sprite_icon("alert", height: "40px", width: "40px", class: "text-red-600")

        expect(html).to have_selector("svg.icon.icon-alert.text-red-600[height='40px'][width='40px']")
        expect(html).to have_selector("use[href$='sprite.svg#alert']", visible: false)
      end
    end

    context "when used with default options" do
      it "renders with default class, height, and width" do
        html = helper.sprite_icon("check")

        expect(html).to have_selector("svg.icon.icon-check[height='24px'][width='24px']")
        expect(html).to have_selector("use[href$='sprite.svg#check']", visible: false)
      end
    end

    context "when used with multiple data attributes" do
      it "renders with tooltip and controller attributes" do
        html = helper.sprite_icon("info", class: "text-blue-400", data: {controller: "tooltip", tooltip_text: "More info"})

        expect(html).to have_selector("svg.icon.icon-info.text-blue-400[data-controller='tooltip'][data-tooltip-text='More info']")
        expect(html).to have_selector("use[href$='sprite.svg#info']", visible: false)
      end
    end
  end
end
