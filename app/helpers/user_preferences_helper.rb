# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module UserPreferencesHelper
  def selectable_locales_with_translation_level(minimum_level = TranspoLink::I18n::MINIMUM_TRANSLATION_LEVEL)
    TranspoLink::I18n.selectable_locales(minimum_level).map do |code, language|
      [
        t(".language_translation_percentage", locale: code) % {
          language: language,
          percent_translated: "#{TranspoLink::I18n.percentage_translated_for(code)}%"
        },
        code
      ]
    end
  end
end
