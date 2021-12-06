require "action_mailbox/test_helper"

RSpec.configure do |config|
  config.include ActionMailbox::TestHelper, type: :mailbox
end
