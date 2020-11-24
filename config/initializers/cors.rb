Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:3000"
    resource "*", headers: :any, expose: ["Authorization"], methods: [:get, :post, :put, :patch, :delete, :options, :head], credentials: true
  end

  allow do
    origins "https://the97062lab.herokuapp.com"
    resource "*", headers: :any, expose: ["Authorization"], methods: [:get, :post, :put, :patch, :delete, :options, :head], credentials: true
  end

  # allow do
  #   origins "http://the97062lab.herokuapp.com"
  #   resource "*", headers: :any, expose: ["Authorization"], methods: [:get, :post, :put, :patch, :delete, :options, :head], credentials: true
  # end

  # allow do
  #   origins "*"
  #   resource(
  #     "*",
  #     headers: :any,
  #     expose: ["Authorization"],
  #     methods: [:get, :patch, :put, :delete, :post, :options, :show],
  #     credentials: true,
  #   )
  # end
end
