require 'acts_as_warnable/version'
require 'acts_as_warnable/engine'
require 'acts_as_warnable/rails/routes'

module ActsAsWarnable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def acts_as_warnable(options = {})
      has_many :warnings, as: :warnable
      include WarnableInstanceMethods
    end
  end

  module WarnableInstanceMethods
    def issue_warning(message)
      warning = warnings.create(message: message)

      if respond_to?(:create_activity)
        create_activity(
          key: 'warning.issue',
          recipient: warning
        )
      end
    end
  end
end

ActiveRecord::Base.send :include, ActsAsWarnable
