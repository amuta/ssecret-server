namespace :user do
  desc "Creates a new admin user. Usage: rake user:create[username,'ssh_public_key']"
  task :create, [ :username, :ssh_public_key ] => :environment do |_task, args|
    username = args[:username]
    ssh_public_key = args[:ssh_public_key]

    if username.blank? || ssh_public_key.blank?
      puts "❌ Error: Username and public key must be provided."
      puts "Usage: rake user:create['your_username','your_ssh_public_key_string']"
      exit 1
    end

    begin
      user = User.new(
        username: username,
        ssh_public_key: ssh_public_key,
        admin: true
      )

      if user.save
        puts "✅ Admin user '#{user.username}' created successfully."
      else
        puts "❌ Error creating user: #{user.errors.full_messages.join(', ')}"
        exit 1
      end
    rescue => e
      puts "An unexpected error occurred: #{e.message}"
      exit 1
    end
  end
end
