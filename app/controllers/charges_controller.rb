class ChargesController < ApplicationController
  include StripeHandlerModule

  def index
  end

  def create
    # Get the parameters required to make a charge
    # Amount will also be used to select the api response we want to get back
    # from testing pays
    amount = params[:amount]
    token = params[:stripeToken]

    if token
      # Create a charge with the token
      charge = create_charge(amount, token)
    else
      # Use the card details passed in:
      card_details = {
        exp_month: params["expiry-month"],
        exp_year: params["expiry-year"],
        number: params["card-number"].gsub(" ", ""),
        cvc: params["cvv"],
        object: "card"
      }

      charge = create_charge(amount, card_details)
    end

    # Check if there was an error with the charge
    if charge[:error]
      render(json: charge[:error], status: charge[:status]) && return
    end

    # No errors, return the charge to the user
    render json: charge
  end
end
