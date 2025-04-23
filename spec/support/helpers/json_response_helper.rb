# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module JsonResponseHelper
  def parsed_response_body
    JSON.parse(response.body)
  rescue JSON::ParserError
    raise "Failed to parse response body as JSON: #{response.body}"
  end
end
