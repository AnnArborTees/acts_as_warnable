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
      extend WarnableClassMethods
    end
  end

  module WarnableClassMethods
    def warn_on_failure_of(*methods)
      methods.each do |method_name|
        define_method "#{method_name}_with_warning" do |*args, &block|
          begin
            send("#{method_name}_without_warning", *args, &block)
          rescue Exception => e
            issue_warning(
              warning_source(method_name),
              "#{e.class.name}: #{e.message}\n\n#{e.backtrace.join("\n")}"
            )
          end
        end
        alias_method_chain method_name, :warning
      end
    end
  end

  module WarnableInstanceMethods
    def warning_source(method_name)
      "#{self.class.name}##{method_name}"
    end

    def issue_warning(source, message)
      warning = warnings.create(source: source, message: message)

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
