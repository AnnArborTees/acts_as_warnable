class WarningEmail < ActiveRecord::Base
  validates :recipient, name_and_email: true
  validate :model_is_actually_a_model

  def warnings
    ActsAsWarnable::Warning.where(warnable_type: model, dismissed_at: nil)
  end

  def send_report
    WarningEmailMailer.send_report(self, warnings).deliver
  end

  def self.spawn_sender_thread
    Thread.main[:warning_email_sender] = Thread.new do
      loop do
        begin
          warning_times = {}

          min_wait_time = 600
          WarningEmail.find_each do |warning_email|
            next if warning_email.minutes.blank?

            warning_times[warning_email.id] ||= Time.now.to_i
            wait_time = warning_email.minutes * 60.0 - (Time.now.to_i - warning_times[warning_email.id])

            if wait_time < 0
              warning_email.send_report if warning_email.warnings.any?
              warning_times[warning_email.id] = Time.now.to_i
              wait_time = warning_email.minutes * 60.0
            end

            min_wait_time = wait_time if wait_time < min_wait_time
          end

          ActiveRecord::Base.clear_active_connections!
          sleep min_wait_time.seconds + 1
        rescue StandardError => e
          Rails.logger.error "WARNING_EMAILS ERROR DURING LOOP #{e.class.name}: #{e.message}"

          ActiveRecord::Base.clear_active_connections!
          sleep 1.minute
        end
      end
    end
  end

  private

  def model_is_actually_a_model
    model_class = model.constantize
    unless model_class.ancestors.include?(ActiveRecord::Base)
      errors.add 'model', 'must correspond to a valid model'
    end
  end
end
