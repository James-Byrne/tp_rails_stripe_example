class DonationsController < ApplicationController
  include StripeHandlerModule

  def index
  end

  def create
    # Get the parameters required to make a charge
    # Amount will also be used to select the api response we want to get back
    # from testing pays
    amount = params[:amount]
    token = params[:stripeToken]

    # Create a charge
    charge = create_charge(amount, token)

    # Check if there was an error with the charge
    if charge[:error]
      render(json: charge[:error], status: charge[:status]) && return
    end

    # No errors, return the charge to the user
    render json: charge
  end
end
