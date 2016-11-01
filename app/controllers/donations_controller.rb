require "stripe"

class DonationsController < ApplicationController
  def index
  end

  def create
    # Get the parameters required to make a charge
    # Amount will also be used to select the api response we want to get back
    # from testing pays
    amount = params[:amount]
    token = params[:stripeToken]

    # Set your stripe API Key here
    Stripe.api_key = "30d0b8f9c831bcdb2ae501f37e7f48e4"

    # Create a charge
    charge = create_charge(amount, token)

    # Check if there was an error with the charge
    if charge[:errors]
      render(json: {errors: charge[:errors]}, status: 422) && return
    end

    # No errors, return the charge to the user
    render json: charge
  end

  # Create a charge
  def create_charge(amount, token)
    result = stripe_handler do
      Stripe::Charge.create(
        :amount => (amount.to_f * 100).to_i,
        :currency => "usd",
        :source => token,
        :description => "Charge for testing.pays@example.com"
      )
    end

    return result
  end

  def stripe_handler
    begin
      result = yield
    rescue Stripe::CardError,
      Stripe::RateLimitError,
      Stripe::InvalidRequestError,
      Stripe::AuthenticationError,
      Stripe::APIConnectionError,
      Stripe::StripeError => e

      errors = {errors: {message: e.message, backtrace: e.backtrace}}
    rescue => e
      # Something else happened, completely unrelated to Stripe
      Rails.logger.info "500 error"
      Rails.logger.info e.message
      Rails.logger.info e.backtrace

      errors = {errors: {stripe_token: "There was an error with the payment, please try again in a moment"}}
    end

    # Return the result or errors from the request
    return result || errors
  end
end
