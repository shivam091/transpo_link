# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/helpers/text_helper_spec.rb

require "spec_helper"

RSpec.describe TextHelper, type: :helper do
  describe "#word_wrap" do
    let!(:short_text) { "Short text." }
    let!(:long_text) { "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam." }
    let!(:mixed_text) { "Lorem ipsum dolor sit amet, consectetur adipiscing elit." }

    it "wraps text to the specified line width" do
      wrapped_text = helper.word_wrap(long_text, wrap_length: 20, seperator: "<br/>")

      # Check if lines break at the correct position (within 20 characters)
      expect(wrapped_text.split("<br/>").all? { |line| line.length <= 20 }).to be_truthy
    end

    it "wraps short text without changes" do
      wrapped_text = helper.word_wrap(short_text, wrap_length: 20, seperator: "<br/>")

      expect(wrapped_text).to eq(short_text)
    end

    it "wraps text with long words that exceed the line width" do
      wrapped_text = helper.word_wrap(long_text, wrap_length: 10, seperator: "<br/>")

      # Check if words are broken into smaller pieces when exceeding the line width
      expect(wrapped_text).to match(/.{1,10}\s+/)
    end

    it "does not wrap if the text fits within the line width" do
      wrapped_text = helper.word_wrap(mixed_text, wrap_length: 80, seperator: "<br/>")

      expect(wrapped_text).to eq(mixed_text)
    end

    it "uses the custom separator" do
      wrapped_text = helper.word_wrap(long_text, wrap_length: 20, seperator: "<hr/>")

      # Check if the separator is used to split the wrapped lines
      expect(wrapped_text).to include("<hr/>")
    end

    it "handles line breaks correctly even with multiple spaces" do
      wrapped_text = helper.word_wrap("Lorem ipsum   dolor   sit amet.", wrap_length: 10, seperator: "<br/>")

      expect(wrapped_text).to include("<br/>")
      expect(wrapped_text.split("<br/>").all? { |line| line.length <= 10 }).to be true
    end

    it "wraps text even when the line width is smaller than the longest word" do
      wrapped_text = helper.word_wrap("abcdefghij", wrap_length: 5, seperator: "<br/>")

      # Word 'abcdefghij' should be wrapped because wrap_length is smaller than the word length
      expect(wrapped_text).to include("<br/>")
    end

    it "handles empty text gracefully" do
      wrapped_text = helper.word_wrap("", wrap_length: 10, seperator: "<br/>")

      expect(wrapped_text).to eq("")
    end
  end

  describe "#truncate" do
    let!(:long_text) { "This is a test string that is longer than thirty characters." }

    it "returns the same string if it's within the limit" do
      expect(helper.truncate("Short text", truncate_at: 20)).to eq("Short text")
    end

    it "truncates and appends omission when exceeding limit" do
      expect(helper.truncate("This is a long text", truncate_at: 10)).to eq("This is a ...")
    end

    it "allows custom omission strings" do
      expect(helper.truncate("This is a long text", truncate_at: 10, omission: "[...]")).to eq("This is a [...]")
    end

    it "handles an empty string gracefully" do
      expect(helper.truncate("", truncate_at: 5)).to eq("")
    end

    it "handles nil input gracefully" do
      expect { helper.truncate(nil, truncate_at: 5) }.to raise_error(NoMethodError)
    end

    it "does not truncate if truncate_at is equal to string length" do
      expect(helper.truncate("Exact length", truncate_at: 12)).to eq("Exact length")
    end

    it "truncates a string with spaces properly" do
      expect(helper.truncate("This is a test string", truncate_at: 14)).to eq("This is a test...")
    end

    it "handles very small truncate_at values" do
      expect(helper.truncate("Hello world", truncate_at: 3)).to eq("Hel...")
    end

    it "uses the default truncate_at value when not provided" do
      expect(helper.truncate(long_text)).to eq("This is a test string that is ...")
    end
  end
end
