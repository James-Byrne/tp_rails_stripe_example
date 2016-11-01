$(function () {

  // Set your stripe publishable key here
  Stripe.setPublishableKey('pk_test_reFgElntVfcZYDzydQBhfrMj');

  /**
   * Take control of the form submission. Prevent the default submission
   * behaviour and retrieve a stripe token first
   */
  $('#stripe-form').submit( function (e) {
    e.preventDefault();

    Stripe.card.createToken({
      number: $('#card-number').val(),
      cvc: $('#cvc').val(),
      exp_month: $('#expiry-month').val(),
      exp_year: $('#expiry-year').val()
    }, stripeResponseHandler);

    $('#submit-btn').prop("disabled", true);
  });

  /**
   * Sends a post request to the donation_controller with the amount and token
   * attributes.
   *
   * @method stripeResponseHandler
   * @param   status     The status response returned from the api
   * @param   response   The response from the api
   */
  function stripeResponseHandler(status, response) {
    if (response.error) {
      // Show the errors on the form
      $('#form-errors').show();
      $('#form-errors').html(response.error.message);

    } else {
      // Send a post request to the charges route
      $.post('/donations', {stripeToken: response.id, amount: $('#amount').val()}).always(function() {
        $('#submit-btn').prop("disabled", false);
      });
    }
  };

});
