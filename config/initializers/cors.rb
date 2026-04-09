# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ApiCors.allowed_origins)
    resource "/api/*",
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: false
  end
end

# Origins allowed for the React SPA (Vite defaults + comma-separated FRONTEND_ORIGIN).
module ApiCors
  module_function

  def allowed_origins
    env = ENV.fetch("FRONTEND_ORIGIN", "")
    defaults = if Rails.env.development?
                 [ "http://localhost:5173", "http://127.0.0.1:5173" ]
               else
                 []
               end
    (defaults + env.split(",").map(&:strip).reject(&:blank?)).uniq
  end
end
