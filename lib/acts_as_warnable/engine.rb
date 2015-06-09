module ActsAsWarnable
  class Engine < ::Rails::Engine
    isolate_namespace ActsAsWarnable
    initializer 'acts_as_warnable.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        helper ActsAsWarnable::ApplicationHelper
      end
    end
  end
end
