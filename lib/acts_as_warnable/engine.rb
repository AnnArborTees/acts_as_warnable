module ActsAsWarnable
  class Engine < ::Rails::Engine
    isolate_namespace ActsAsWarnable

    initializer 'acts_as_warnable.register_md_mime' do
      unless Mime::Type.lookup_by_extension(:md)
        Mime::Type.register "text/markdown", :md
      end
    end
    
    initializer 'acts_as_warnable.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        require_relative '../../app/helpers/acts_as_warnable/application_helper'
        helper ActsAsWarnable::ApplicationHelper
      end
    end
  end
end
