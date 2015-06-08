require 'acts_as_warnable/version'
require 'acts_as_warnable/engine'

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
      warnings.create(message: message)
    end
    # TODO public activity? Perhaps in the controller
  end


end

ActiveRecord::Base.send :include, ActsAsWarnable
