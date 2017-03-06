require 'test_helper'
require 'minitest/mock'

class ChargesControllerTest < ActionController::TestCase

  test "should create a successful charge with status code of 200" do
    post :create, params: {
      amount: 200,
      stripeToken: 1234567890
    }

    assert_response 200
    assert_match "success", JSON.parse(response.body)["status"]
  end

  test "should create a successful charge with address_zip_check of fail" do
    post :create, params: {
      amount: 200.10,
      stripeToken: 1234567890
    }

    json_result = JSON.parse(response.body)
    assert_response 200
    assert_match "success", json_result["status"]
    assert_match "pass", json_result['source']['address_line1_check']
    assert_match "pass", json_result['source']['cvc_check']
    assert_match "fail", json_result['source']['address_zip_check']
  end

  test "should required parameter is missing with status code of 400" do
    post :create, params: {
      amount: 200.80,
      stripeToken: 1234567890
    }
    assert_response 400
    json_result = JSON.parse(response.body)
    assert_match "invalid_request_error", json_result["type"]
    assert_match "amount", json_result["param"]
  end

  test "should render type card_error with status code of 402 and code of expired_card" do
    post :create, params: {
      amount: 200.81,
      stripeToken: 1234567890
    }

    assert_response 402
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "card_error", json_result["type"]
    assert_match "expired_card", json_result["code"]
  end

  test "should render type card_error with status code of 402 and code of card_declined" do
    post :create, params: {
      amount: 200.82,
      stripeToken: 1234567890
    }

    assert_response 402
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "card_error", json_result["type"]
    assert_match "card_declined", json_result["code"]
  end

  test "should render type card_error with status code of 402 and code of missing" do
    post :create, params: {
      amount: 200.83,
      stripeToken: 1234567890
    }

    assert_response 402
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "card_error", json_result["type"]
    assert_match "missing", json_result["code"]
  end

  test "should render type card_error with status code of 402 and code of processing" do
    post :create, params: {
      amount: 200.84,
      stripeToken: 1234567890
    }

    assert_response 402
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "card_error", json_result["type"]
    assert_match "processing", json_result["code"]
  end

  test "should render type api_connection_error with status code of 400" do
    post :create, params: {
      amount: 200.85,
      stripeToken: 1234567890
    }

    assert_response 400
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "api_connection_error", json_result["type"]
  end

  test "should render type authentication_error with status code of 401" do
    post :create, params: {
      amount: 200.86,
      stripeToken: 1234567890
    }

    assert_response 401
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "authentication_error", json_result["type"]
  end

  test "should render type conflict with status code of 409" do
    post :create, params: {
      amount: 200.87,
      stripeToken: 1234567890
    }

    assert_response 409
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "conflict", json_result["type"]
  end

  test "should render type too_many_requests with status code of 429" do
    post :create, params: {
      amount: 200.88,
      stripeToken: 1234567890
    }

    assert_response 429
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "too_many_requests", json_result["type"]
  end

  test "should render type api_error with status code of 400" do
    post :create, params: {
      amount: 200.89,
      stripeToken: 1234567890
    }

    assert_response 400
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "api_error", json_result["type"]
  end

  test "should render type authentication_error with status code of 400" do
    post :create, params: {
      amount: 200.90,
      stripeToken: 1234567890
    }

    assert_response 400
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "authentication_error", json_result["type"]
  end

  test "should render type rate_limit_error with status code of 429" do
    post :create, params: {
      amount: 200.91,
      stripeToken: 1234567890
    }

    assert_response 429
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "rate_limit_error", json_result["type"]
  end

  test "should render type server_error with status code of 500" do
    post :create, params: {
      amount: 200.92,
      stripeToken: 1234567890
    }

    assert_response 500
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "server_error", json_result["type"]
  end

  test "should render type server_error with status code of 502" do
    post :create, params: {
      amount: 200.93,
      stripeToken: 1234567890
    }

    assert_response 502
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "server_error", json_result["type"]
  end

  test "should render type server_error with status code of 503" do
    post :create, params: {
      amount: 200.94,
      stripeToken: 1234567890
    }

    assert_response 503
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "server_error", json_result["type"]
  end

  test "should render type server_error with status code of 504" do
    post :create, params: {
      amount: 200.95,
      stripeToken: 1234567890
    }

    assert_response 504
    json_result = JSON.parse(response.body)

    assert_not_nil json_result["type"]
    assert_match "server_error", json_result["type"]
  end

  test "should render timeout" do
    assert_raises(Timeout::Error) do
      Timeout::timeout(3) do
          post :create, params: {
            amount: 200.96,
            stripeToken: 1234567890
          }
      end
    end
  end

end
