require "sib-api-v3-sdk"

# Setup authorization
SibApiV3Sdk.configure do |config|
  config.api_key["api-key"] = ENV["SENDINBLUE_API_KEY"]
  config.api_key["partner-key"] = ENV["SENDINBLUE_API_KEY"]
end
