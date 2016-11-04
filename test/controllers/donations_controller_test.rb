require 'test_helper'
require 'minitest/mock'

class DonationsControllerTest < ActionController::TestCase

  test "should create a successful charge" do
    post :create, params: {
      amount: 200,
      stripeToken: 1234567890
    }

    assert_response 200
    json_result = JSON.parse(response.body)

    assert_match "success", json_result["status"]
  end

  test "should render a card error" do
    post :create, params: {
      amount: 200.81,
      stripeToken: 1234567890
    }

    assert_response 422
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "card_error", json_result["type"]
  end
end
