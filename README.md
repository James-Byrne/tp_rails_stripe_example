# Testing Pays
<img src="TestingPaysLogo.png" width="250" height="200" align="right">
> Demonstrating how Testing Pays API can be used to test Stripe's payment processor.

### Existing Projects
To integrate an existing project with TestingPays we recommend you follow the short guide on your [instructions page](https://admin.testingpays.com/teams_apis/stripe-v1-charges).

### Requirements
In order to run this application you will need the following:
- [ruby](https://www.ruby-lang.org/en/) (version 2.2+)
  - We recommend you use [rvm](https://rvm.io/) to manage your ruby versions
  - If you are using windows you can find a ruby installer [here](http://rubyinstaller.org/downloads/)


- [node.js](https://nodejs.org/en/) (latest LTS)


##### Accounts
You will also require an account with both [Stripe](https://stripe.com/) and [TestingPays](http://www.testingpays.com/).

### Setup
Firstly pull down the repo.
``` bash
$ git clone https://github.com/ThePaymentWorks/tp_rails_stripe_example.git
```

Next enter the directory and install the applications dependencies.

``` bash
$ cd tp_rails_stripe_example/
$ bundle install
```

##### API Keys
In order to work with Stripe we need to provide our [Publishable api key](https://stripe.com/docs/dashboard#api-keys). This is the key Stripe uses to [create tokens](https://stripe.com/docs/api#create_card_token).

Open [donations.js](app/assets/javascripts/donations.js) and replace `'YOUR-PUBLISHABLE-KEY'` with the key [stripe gave you](https://support.stripe.com/questions/where-do-i-find-my-api-keys).

```js
// app/assets/javascripts/donations.js
Stripe.setPublishableKey('YOUR-PUBLISHABLE-KEY');
```

Last thing we need to do before starting the application is insert our TestingPaysapi key. You can find that in the [instructions](https://admin.testingpays.com/teams_apis/stripe-v1-charges) or in your [team page](https://admin.testingpays.com/teams). Open [stripe_handler_module](app/controllers/concerns/stripe_handler_module.rb) Insert your API key in place of `"YOUR-API-KEY-HERE"`.

```ruby
# app/controllers/concerns/stripe_handler_module.rb

# Set the stripe API key when we include the module
included do
  Stripe.api_key = "YOUR-API-KEY-HERE" # tp api key
end
```

### Running the application
Now that we have the application installed and our api keys setup we can start using the application. Firstly lets run the tests to make everything is in order.

```bash
$ rails t
```

Your tests should have ran successfully. Now to run the application use the following command.

```bash
$ rails s
```

Your application should now be running [locally](http://localhost:3000/donations).


### Integrating with TestingPays
We do not recommend you use this application in production. It is just for example purposes.

This application points to the TestingPays Stripe charges api when running in both development and testing modes. This is set in the [testing_pays initializer](config/initializers/testing_pays.rb).

```ruby
# config/initializers/testing_pays.rb
if Rails.env.development? || Rails.env.test?
  module Stripe
    @api_base = "https://api.testingpays.com/stripe"
  end
end
```


### Testing with TestingPays
TestingPays makes testing many types of responses easy. In order to get a particular response simply pass in the associated response mapping. E.g.

```ruby
amount: 91  # => rate_limit_error
amount: 80  # => card_expired
amount: 0   # => success
```

For a full list of response mappings see the [response mappings table](https://admin.testingpays.com/teams_apis/stripe-v1-charges).

```ruby
# test/controllers/donations_controller_test.rb

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

```
