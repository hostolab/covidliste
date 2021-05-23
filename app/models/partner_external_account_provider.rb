class PartnerExternalAccountProvider < ApplicationRecord
  module Providers
    ALL = {pro_sante_connect: "Pro Santé Connect", bimedoc: "Bimedoc"}.select { |p, n| ENV["#{p.upcase}_CLIENT_SECRET"] }.freeze
  end
end
