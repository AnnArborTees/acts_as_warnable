module ActsAsWarnable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def acts_as_warnable(options = {})
    end
  end

  module LocalInstanceMethods
  end


end

ActiveRecord::Base.send :include, ActsAsWarnable
