require "sib-api-v3-sdk"
SibApiV3Sdk.configure do |config|
  config.api_key["api-key"] = ENV["SENDINBLUE_API_KEY"]
end
Rails.application.config.postmark_api_key = ENV["POSTMARK_API_TOKEN"]
