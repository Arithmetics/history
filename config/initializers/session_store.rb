if Rails.env == "production"
  Rails.application.config.session_store :disabled
else
  Rails.application.config.session_store :disabled
end
