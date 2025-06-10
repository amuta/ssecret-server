# file: lib/tasks/user.rake

namespace :user do
  desc "Create a new user with a given username and public key"
  task :create, [ :username, :public_key_string ] do |t, args|
    username = args[:username]
    key_string = args[:public_key_string]

    if username.blank? || key_string.blank?
      puts "Usage: rake user:create['<username>','<public_key_string>']"
      exit 1
    end

    puts "Attempting to create user '#{username}'..."

    # Call the new, namespaced service.
    result = Users::CreateService.call(
      username: username,
      raw_public_key: key_string,
      admin: true # Assuming users created via this task should be admins
    )

    # Interact with the standardized Result object.
    if result.success?
      user = result.payload
      puts "Successfully created user:"
      puts "  ID:       #{user.id}"
      puts "  Username: #{user.username}"
      puts "  Key Hash: #{user.public_key_hash}"
    else
      puts "Failed to create user:"
      puts "  Errors: #{result.errors.join(', ')}"
    end
  end
end
