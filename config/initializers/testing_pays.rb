# config/initializers/testing_pays.rb
if Rails.env.development? || Rails.env.test?
  module Stripe
    @api_base = "https://api.testingpays.com/stripe"
  end
end
