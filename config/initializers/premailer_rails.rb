Premailer::Adapter.use = :nokogiri_fast
# https://github.com/premailer/premailer#adapters

Premailer::Rails.config.merge!(strategies: [])
# We only want text part generation so we remove all strategies
