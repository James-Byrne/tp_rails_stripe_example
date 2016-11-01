require 'test_helper'
require 'minitest/mock'

class DonationsControllerTest < ActionController::TestCase

  test "should create a successful charge with status code of 200" do
    post :create, params: {
      amount: 200,
      stripeToken: 1234567890
    }

    assert_response 200
    assert_match "success", JSON.parse(response.body)["status"]
  end

  test "should render a card error with status code of 402" do
    post :create, params: {
      amount: 200.81,
      stripeToken: 1234567890
    }

    assert_response 402
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "card_error", json_result["type"]
  end

  test "should render a rate limit error with status code of 429" do
    post :create, params: {
      amount: 200.91,
      stripeToken: 1234567890
    }

    assert_response 429
    assert_match "rate_limit_error", JSON.parse(response.body)["type"]
  end

end
