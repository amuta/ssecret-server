require 'rails_helper'
require 'rake'



RSpec.describe 'user:create' do
  let(:username) { 'rake_user' }
  let(:public_key) { OpenSSL::PKey::RSA.new(2048).public_key.to_pem }
  let(:task) { Rake::Task['user:create'] }

  before do
    Rake.load_rakefile("tasks/user.rake")
  end

  it 'calls the Users::CreateService with the correct parameters' do
    # Expect the service to be called with the arguments from the task
    expect(Users::CreateService).to receive(:call).with(
      username: username,
      raw_public_key: public_key,
      admin: true
    ).and_return(ApplicationService::Result.new(true, build(:user), nil))

    # Invoke the task with arguments
    task.invoke(username, public_key)
  end
end
