namespace :populate do
  desc "Generate fake users"
  task users: :environment do
    puts "How many users do you want? (~1s / user)"
    print "> "
    # count = gets.chomp.to_i
    count = 3
    puts "Generating #{count} users..."
    count.times do |i|
      user = User.new(
        email: Faker::Internet.unique.email(domain: "covidliste.com"),
        birthdate: Faker::Date.between(from: 100.years.ago, to: 18.years.ago),
        address: Faker::Address.full_address,
        phone_number: "+33601020304",
        toc: true,
        statement: true,
        lat: rand(41.5..42.5),
        lon: rand(1.5..2.5)
      )
      user.skip_confirmation!
      user.save!
      user.update_columns(confirmed_at: Time.now.utc)
      GeocodeResourceJob.perform_now(user)
      user.reload
      puts "#{i + 1}. #{user}, #{user.age} ans - #{user.address} (#{user.lat}, #{user.lon})"
    end
    puts "Done."
  end

  desc "Generate lot of data: this was designed at testing inactive user query"
  task generate_many_users_and_matches: :environment do
    params = {
      users_count: 2_000_000,
      min_users_id: 5_000_000,
      matches_count: 500_000,
      min_matches_id: 5_000_000,
      matches_per_user: 30,
      matches_cycle: 500_000 / 30
    }

    query = ActiveRecord::Base.send(:sanitize_sql_array, [<<~SQL, params])
      begin;
      delete from matches where id > :min_matches_id;
      delete from users where id > :min_users_id;
      commit;
    SQL
    User.connection.execute(query)

    #
    # Users
    #
    query = ActiveRecord::Base.send(:sanitize_sql_array, [<<~SQL, params])
      insert into users(id, birthdate, created_at, anonymized_at, updated_at)
      select
        :min_users_id + c.i as id
        , now() - (mod(c.i, 80) + 17) * interval '1 year' as birthdate
        , now() - mod(c.i, 300) * interval '1 minute' as created_at
        , NULL as anonymized_at
        , now() as updated_at
      from generate_series(1, :users_count) c(i)
    SQL
    User.connection.execute(query)

    #
    # Matches
    #
    query = ActiveRecord::Base.send(:sanitize_sql_array, [<<~SQL, params])
      insert into matches(id, user_id, confirmed_at, refused_at, expires_at, created_at, updated_at)
      select
        :min_matches_id + c.i as id
        , :min_users_id + mod(c.i, :matches_cycle) + 1as user_id
        , case
          when mod(c.i, 1000) < 1 then -- 1/1000 confirmed
            now() - mod(c.i, 100) * interval '10 minutes'
          else
            null
          end as confirmed_at
        , case
          when mod(c.i, 100) >= 10 then -- 90% refused
            now() - mod(c.i, 100) * interval '10 minutes'
          else
            null
          end as refused_at
        , now() - (mod(c.i, 100) - 50) * interval '10 minutes' as expires_at
        , now() as created_at
        , now() as updated_at
      from generate_series(1, :matches_count) c(i)
    SQL
    User.connection.execute(query)
  end

  desc "Create a new validated Vaccination center with a new partner"
  task create_vaccination_center_with_partner_and_validate: :environment do
    partner = Partner.new(
      name: Faker::Name.name,
      email: Faker::Internet.email,
      phone_number: Faker::PhoneNumber.phone_number,
      password: "1G09_!9s08vUsa"
    )
    partner.save!(validate: false) # Bypass MX validation

    vaccination_center = VaccinationCenter.new(
      name: "#{Faker::TvShows::GameOfThrones.city} Center",
      description: Faker::Lorem.sentences.join(" "),
      address: Faker::Address.full_address,
      kind: VaccinationCenter::Kinds::ALL.sample,
      lat: 48.864716, # Paris
      lon: 2.349014,
      pfizer: true,
      phone_number: Faker::PhoneNumber.phone_number
    )
    vaccination_center.save!
    vaccination_center.update(confirmed_at: Time.now.utc)
    vaccination_center.partners << partner

    puts "Connexion à '#{vaccination_center.name}' avec le compte professionnel de santé assurant la vaccination : #{partner.email} / #{partner.password}"
  end
end
