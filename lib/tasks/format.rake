namespace :format do
  desc "Format phone numbers"
  task phone_numbers: :environment do
    puts "Formatting User phone numbers..."
    User.find_each do |user|
      user.send :format_phone_number
      user.save
    end
    puts "Done."
  end
end
