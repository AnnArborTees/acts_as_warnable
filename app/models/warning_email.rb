class WarningEmail < ActiveRecord::Base
  validates :recipient, name_and_email: true
  validate :model_is_actually_a_model

  def warnings
    Warning.where(warnable_type: model, dismissed_at: nil)
  end

  def send_report
    WarningEmailMailer.send_report(self)
  end

  private

  def model_is_actually_a_model
    model_class = model.constantize
    unless model_class.ancestors.include?(ActiveRecord::Base)
      errors.add 'model', 'must corrospond to a valid model'
    end
  end
end
