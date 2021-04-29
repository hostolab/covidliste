Rack::Attack.throttle("logins/ip", limit: 40, period: 10.minutes) do |req|
  req.ip if req.post? && req.path.start_with?("/login")
end

Rack::Attack.throttle("partners/login/ip", limit: 40, period: 10.minutes) do |req|
  req.ip if req.post? && req.path.start_with?("/partners/login")
end

Rack::Attack.throttle("partners/password/new", limit: 40, period: 10.minutes) do |req|
  req.ip if req.post? && req.path.start_with?("/partners/password/new")
end

Rack::Attack.throttle("users/password/new", limit: 40, period: 10.minutes) do |req|
  req.ip if req.post? && req.path.start_with?("/users/password/new")
end

ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, req|
  Rais.logger.warning("Throttled #{req.env["rack.attack.match_discriminator"]}")
end
