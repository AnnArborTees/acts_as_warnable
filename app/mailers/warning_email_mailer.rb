class WarningEmailMailer < ActionMailer::Base
  def send_report(warning_email, warnings)
    @warning_email = warning_email

    mail(
      to: @warning_email.recipient,
      from: ENV['warning_email_sender'] || raise('Please set ENV["warning_email_sender"]'),
      subject: "[#{Time.now.strftime('%D %r')}] There are outstanding warnings for #{@warning_email.model}",
    )
  end
end
