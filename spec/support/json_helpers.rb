# frozen_string_literal: true

# Shared helpers for JSON API request specs (TDD-friendly defaults).
module JsonHelpers
  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include JsonHelpers, type: :request
end
