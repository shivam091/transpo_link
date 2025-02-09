# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/links_helper_spec.rb

require "spec_helper"

RSpec.describe LinksHelper, type: :helper do
  describe "#link_to" do
    context "when html_options[:class] is an array" do
      it "removes blank values from the class array" do
        result = helper.link_to("Home", "/", class: ["btn", "", nil, "primary"])
        expect(result).to eq('<a class="btn primary" href="/">Home</a>')
      end

      it "leaves the class array unchanged if there are no blank values" do
        result = helper.link_to("Dashboard", "/dashboard", class: ["btn", "secondary"])
        expect(result).to eq('<a class="btn secondary" href="/dashboard">Dashboard</a>')
      end

      it "removes the class attribute if the array becomes empty after removing blank values" do
        result = helper.link_to("Profile", "/profile", class: ["", nil, " "])
        expect(result).to eq('<a href="/profile">Profile</a>')
      end
    end

    context "when html_options[:class] is not an array" do
      it "does not modify the class attribute if it is a string" do
        result = helper.link_to("Settings", "/settings", class: "btn primary")
        expect(result).to eq('<a class="btn primary" href="/settings">Settings</a>')
      end

      it "does not add a class attribute if none is provided" do
        result = helper.link_to("Logout", "/logout")
        expect(result).to eq('<a href="/logout">Logout</a>')
      end
    end

    context "when used with a block" do
      it "handles block content correctly" do
        result = helper.link_to("/home", class: ["link", "", "nav"]) do
          "Go Home"
        end
        expect(result).to eq('<a class="link nav" href="/home">Go Home</a>')
      end
    end
  end
end
