# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TranspoLink
  class CountryInfo
    attr_reader :country_code, :subdivision_code

    def initialize(country_code, subdivision_code = nil)
      @country_code, @subdivision_code = country_code, subdivision_code
    end

    def country
      @country ||= ISO3166::Country[country_code]
    end

    def subdivision
      @subdivision ||= country&.subdivisions&.dig(subdivision_code)
    end

    def country_name
      country&.translations&.dig(I18n.locale.to_s) || country&.alpha2
    end

    def subdivision_name
      subdivision&.translations&.dig(I18n.locale.to_s) || subdivision&.name
    end

    def options_for_subdivisions
      return [] unless country&.subdivisions.present?

      country.subdivisions.map do |code, subdivision|
        [(subdivision.translations[I18n.locale.to_s] || subdivision.name), code]
      end
    end

    class << self
      def options_for_countries
        ISO3166::Country.translations(I18n.locale).map do |iso_code, name|
          [name, iso_code]
        end
      end
    end
  end
end
