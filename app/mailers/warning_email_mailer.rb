class WarningEmailMailer < ActionMailer::Base
  def send_report(warning_email, warnings)
    @warning_email = warning_email
    @warnings = warnings
    @site_url = defined?(Figaro) ? Figaro.env.site_url : ENV['SITE_URL']

    mail(
      to: @warning_email.recipient,
      from: (defined?(Figaro) ? Figaro.env.warning_email_sender : ENV['WARNING_EMAIL_SENDER']) || raise('Please set ENV["WARNING_EMAIL_SENDER"]'),
      subject: "[#{Time.now.strftime('%D %r')}] There are outstanding warnings for #{@warning_email.model}",
    )
  end
end
