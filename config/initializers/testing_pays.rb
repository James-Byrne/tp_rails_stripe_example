# config/initializers/testing_pays.rb
if Rails.env.development? || Rails.env.test?
  module Stripe
    @api_base = "https://api.testingpays.com/#{ENV['TP_API_KEY']}/v1/stripe"
  end
end
