if Rails.env == "production"
  Rails.application.config.session_store :cookie_store, key: "_history_97062", domain: "history-97062-api.herokuapp.com"
else
  Rails.application.config.session_store :cookie_store, key: "_history_97062"
end
