# config/initializers/testing_pays.rb
if Rails.env.development? || Rails.env.test?
  module Stripe
    @api_base = "http://0.0.0.0:8000/#{ENV["YOUR_API_KEY"]}/stripe"
  end
end
