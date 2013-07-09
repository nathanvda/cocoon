config = Rails.application.config

if Rails.rails4?
  config.secret_key_base = '58698a8f83e3ccc8e503d18280e17a23008a8f08a6813472dca7873ad0b497428dc00f62ee2225f94bce0d8e04c4befa922e4372772a2e1de89cebaa98a18c0a'
else
  config.secret_token    = '58698a8f83e3ccc8e503d18280e17a23008a8f08a6813472dca7873ad0b497428dc00f62ee2225f94bce0d8e04c4befa922e4372772a2e1de89cebaa98a18c0a'
  config.session_store :cookie_store, :key => "dummy"
end