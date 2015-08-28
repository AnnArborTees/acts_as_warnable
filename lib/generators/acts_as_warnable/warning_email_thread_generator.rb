class ActsAsWarnable::WarningEmailThreadGenerator < Rails::Generators::Base
  desc "Generates an initializer that kicks off a thread that sends warning emails on their intervals."

  source_root File.expand_path("../../templates", __FILE__)

  def create_initializer
    copy_file 'email_initializer.rb', 'config/initializers/send_warning_emails.rb'
  end
end
