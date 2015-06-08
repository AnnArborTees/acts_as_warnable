class Warning < ActiveRecord::Base
  def self.dismisser_class
    Devise.mappings.values.first.class_name
  end

  belongs_to :warnable, polymorphic: true
  if Devise.mappings.size > 1
    Rails.logger.warn "acts_as_warnable does not currently support multiple Devise models. "\
                      "Only #{dismisser_class} will be able to dismiss warnings."
  end
  belongs_to :dismisser, class_name: dismisser_class

  validates :message, presence: true

  default_scope { where(dismissed_at: nil) }

  def dismiss(user)
    update_attributes dismissed_at: Time.now, dismisser: user
  end
end
