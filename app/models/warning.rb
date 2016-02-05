class Warning < ActiveRecord::Base
  def self.dismisser_class
    @dismisser ||= ENV['DISMISSER_CLASS'].try(:constantize) || User
  end

  belongs_to :warnable, polymorphic: true
  belongs_to :dismisser, class_name: dismisser_class

  validates :message, :source, presence: true

  before_save :check_if_dismissed
  after_save :fire_dismissal_activity, if: :just_dismissed?

  scope :active, -> { where(dismissed_at: nil) }

  def dismiss(user)
    update_attributes dismissed_at: Time.now, dismisser: user
  end

  def dismissed?
    !dismissed_at.nil? && !dismisser.nil?
  end

  def just_dismissed?
    @just_dismissed
  end

  protected

  def fire_dismissal_activity
    return unless warnable.respond_to?(:create_activity)

    warnable.create_activity(
      key: 'warning.dismiss',
      recipient: self,
      owner: dismisser
    )
  end

  def check_if_dismissed
    if dismisser_id_changed?
      if dismisser_id.nil?
        self.dismissed_at = nil
      else
        self.dismissed_at = Time.now
        @just_dismissed = true
      end
    end
  end
end
