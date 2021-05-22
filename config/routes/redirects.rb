# Handle old routes redirections (before devise users path migration)

get "/login", to: redirect("/users/login", status: 302), as: :legacy_new_user_session
post "/login", to: redirect("/users/login", status: 302), as: :legacy_user_session
delete "/logout", to: redirect("/users/logout", status: 302), as: :legacy_destroy_user_session
get "/profile", to: redirect("/users/profile", status: 302), as: :legacy_profile
get "/confirmation/new", to: redirect("/users/confirmation/new", status: 302), as: :legacy_new_user_confirmation
get "/confirmation", to: redirect { |_, request| "/users/confirmation#{request.params.present? ? "?" + request.params.to_query : ""}" }, as: :legacy_user_confirmation
