Rails.application.routes.draw do

  api vendor_string: "fooffa",
      default_version: 1,
      path: "",
      defaults: { format: :json } do
    version 1 do
      cache as: 'v1' do
        # Login:
        post "/login", to: "users#login"

        # Test route
        get "/foo", to: "users#foo"
      end
    end
  end

  # Everything else returns a 404:
  get "/*a", to: "application#not_found"
  post "/*a", to: "application#not_found"

  # And the root is, you guessed, a 404:
  root "application#not_found"

end
