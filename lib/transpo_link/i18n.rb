# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TranspoLink
  module I18n
    extend self

    AVAILABLE_LANGUAGES = {
      de: "German - Deutsch",
      en: "English",
      es: "Spanish - Español",
      fr: "French - Français",
      ru: "Russian - Русский",
      pt: "Portuguese - Português",
      zh: "Simplified Chinese - 简体中文"
    }.with_indifferent_access.freeze

    private_constant :AVAILABLE_LANGUAGES

    # Languages with less then MINIMUM_TRANSLATION_LEVEL% of available translations will not
    # be available in the application.
    MINIMUM_TRANSLATION_LEVEL = 2

    TRANSLATION_LEVELS = {
      de: 0,
      en: 100,
      es: 0,
      fr: 0,
      ru: 0,
      pt: 0,
      zh: 1
    }.with_indifferent_access.freeze

    private_constant :TRANSLATION_LEVELS

    def available_locales
      AVAILABLE_LANGUAGES.keys
    end

    def selectable_locales(minimum_translation_level = MINIMUM_TRANSLATION_LEVEL)
      AVAILABLE_LANGUAGES.reject do |code, _name|
        percentage_translated_for(code) < minimum_translation_level
      end
    end

    def locale
      ::I18n.locale
    end

    def percentage_translated_for(code)
      TRANSLATION_LEVELS.fetch(code, 0)
    end

    def locale=(locale_string)
      ::I18n.locale = locale_string
    end

    def with_locale(locale_string, &block)
      original_locale = locale

      self.locale = locale_string
      yield
    ensure
      self.locale = original_locale
    end

    def with_user_locale(user, &block)
      with_locale(user&.preferred_locale, &block)
    end

    def with_default_locale(&block)
      with_locale(::I18n.default_locale, &block)
    end

    def trimmed_language_name(code)
      language_name = AVAILABLE_LANGUAGES[code]
      return if language_name.blank?

      language_name.sub(/\s-\s.*/, "")
    end

    def day_name(day)
      ::I18n.t("date.day_names")[day % 7]
    end

    def day_letter(day)
      ::I18n.t("date.abbr_day_names")[day % 7].first
    end

    def month_name(month)
      ::I18n.t("date.month_names")[month]
    end

    def options_for_languages
      selectable_locales(MINIMUM_TRANSLATION_LEVEL).map do |locale, language|
        [
          ::I18n.t("preferences.preference_form.language_translation_percentage", locale: locale) % {
            language: language,
            percent_translated: "#{percentage_translated_for(locale)}%"
          },
          locale
        ]
      end
    end
  end
end
