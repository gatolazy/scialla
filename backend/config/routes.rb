Rails.application.routes.draw do

  scope :api do
    api vendor_string: "scialla",
        default_version: 1,
        path: "",
        defaults: { format: :json } do
      version 1 do
        cache as: 'v1' do
          # Login:
          post "/login", to: "users#login"
        end
      end
    end
  
    # ActionCable:
    mount ActionCable.server => "/cable"
  
    # Everything else returns a 404:
    get "/*a", to: "application#not_found"
    post "/*a", to: "application#not_found"
  
    # And the root is, you guessed, a 404:
    root "application#not_found"
  end

end

