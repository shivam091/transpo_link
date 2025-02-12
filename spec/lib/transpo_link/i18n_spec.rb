# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# spec/lib/transpo_link/i18n_spec.rb

require "spec_helper"

RSpec.describe TranspoLink::I18n do
  describe "constants" do
    it "defines constant AVAILABLE_LANGUAGES" do
      expect(described_class).to have_constant(:AVAILABLE_LANGUAGES).with_value(
        {
          "de" => "German - Deutsch",
          "en" => "English",
          "es" => "Spanish - Español",
          "fr" => "French - Français",
          "ru" => "Russian - Русский",
          "pt" => "Portuguese - Português",
          "zh" => "Simplified Chinese - 简体中文"
        }
      )
    end

    it "defines constant MINIMUM_TRANSLATION_LEVEL" do
      expect(described_class).to have_constant(:MINIMUM_TRANSLATION_LEVEL).with_value(2)
    end

    it "defines constant AVAILABLE_LANGUAGES" do
      expect(described_class).to have_constant(:TRANSLATION_LEVELS).with_value(
        {
          "de" => 0,
          "en" => 100,
          "es" => 0,
          "fr" => 0,
          "ru" => 0,
          "pt" => 0,
          "zh" => 1
        }
      )
    end
  end

  describe ".available_locales" do
    it "returns all available locale keys" do
      expect(described_class.available_locales).to match_array(%w[de en es fr ru pt zh])
    end
  end

  describe ".selectable_locales" do
    it "returns locales with translations above minimum threshold" do
      expect(described_class.selectable_locales.keys).to match_array(%w[en])
    end

    it "allows custom minimum translation level" do
      expect(described_class.selectable_locales(1).keys).to match_array(%w[en zh])
    end
  end

  describe ".locale" do
    it "returns the current I18n locale" do
      I18n.locale = :en
      expect(described_class.locale).to eq(:en)
    end
  end

  describe ".percentage_translated_for" do
    it "returns the translation percentage for a given locale" do
      expect(described_class.percentage_translated_for(:en)).to eq(100)
      expect(described_class.percentage_translated_for(:zh)).to eq(1)
      expect(described_class.percentage_translated_for(:de)).to eq(0)
    end

    it "returns 0 for unknown locales" do
      expect(described_class.percentage_translated_for(:unknown)).to eq(0)
    end
  end

  describe ".locale=" do
    it "sets the I18n locale" do
      described_class.locale = :en
      expect(I18n.locale).to eq(:en)
    end
  end

  describe ".with_locale" do
    it "temporarily changes the locale for the block" do
      I18n.locale = :en
      described_class.with_locale(:es) do
        expect(I18n.locale).to eq(:es)
      end
      expect(I18n.locale).to eq(:en)
    end
  end

  describe ".with_user_locale" do
    let(:user) { double("User", preferred_locale: :es) }
    let(:default_locale) { :en }

    before do
      I18n.default_locale = default_locale
      I18n.locale = default_locale
    end

    it "sets the locale to the user's preferred locale for the duration of the block" do
      TranspoLink::I18n.with_user_locale(user) do
        expect(I18n.locale).to eq(:es)
      end
    end

    it "reverts to the original locale after the block" do
      TranspoLink::I18n.with_user_locale(user) {}
      expect(I18n.locale).to eq(default_locale)
    end
  end

  describe ".with_default_locale" do
    let(:default_locale) { :en }

    before do
      I18n.default_locale = default_locale
      I18n.locale = :es  # Simulate a different current locale
    end

    after do
      I18n.locale = :en
    end

    it "sets the locale to the default locale for the duration of the block" do
      TranspoLink::I18n.with_default_locale do
        expect(I18n.locale).to eq(default_locale)
      end
    end

    it "reverts to the original locale after the block" do
      TranspoLink::I18n.with_default_locale {}
      expect(I18n.locale).to eq(:es)
    end
  end

  describe ".trimmed_language_name" do
    it "returns the trimmed language name without additional info" do
      expect(described_class.trimmed_language_name(:de)).to eq("German")
      expect(described_class.trimmed_language_name(:es)).to eq("Spanish")
      expect(described_class.trimmed_language_name(:en)).to eq("English")
    end

    it "returns nil for unknown locales" do
      expect(described_class.trimmed_language_name(:unknown)).to be_nil
    end
  end

  describe ".day_name" do
    it "returns the full name of the day" do
      expect(described_class.day_name(1)).to eq("Monday")
    end
  end

  describe ".day_letter" do
    it "returns the first letter of the abbreviated day name" do
      expect(described_class.day_letter(2)).to eq("T")
    end
  end

  describe ".month_name" do
    it "returns the full name of the month" do
      expect(described_class.month_name(3)).to eq("March")
    end
  end

  describe "#options_for_languages" do
    before do
      allow(TranspoLink::I18n).to receive(:selectable_locales).and_return({
        en: "English",
        es: "Spanish - Español"
      })
      allow(TranspoLink::I18n).to receive(:percentage_translated_for).with(:en).and_return(100)
      allow(TranspoLink::I18n).to receive(:percentage_translated_for).with(:es).and_return(10)
    end

    it "returns locales that meet the translation threshold with formatted strings" do
      expect(I18n).to receive(:t).with("preferences.preference_form.language_translation_percentage", locale: :en).and_return("%{language} (%{percent_translated} translated)")
      expect(I18n).to receive(:t).with("preferences.preference_form.language_translation_percentage", locale: :es).and_return("%{language} (%{percent_translated} translated)")

      result = described_class.options_for_languages

      expect(result).to eq([
        ["English (100% translated)", :en],
        ["Spanish - Español (10% translated)", :es]
      ])
    end
  end
end
