require 'acts_as_warnable/version'
require 'acts_as_warnable/engine'
require 'acts_as_warnable/rails/routes'
require 'acts_as_warnable/warning_view'

module ActsAsWarnable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_warnable(options = {})
      has_many :warnings, as: :warnable
      include WarnableInstanceMethods
      extend WarnableClassMethods
    end
  end

  module WarnableClassMethods
    def warn_on_failure_of(*methods)
      options = methods.last.is_a?(Hash) ? methods.pop : {}

      methods.each do |method_name|
        define_method "#{method_name}_with_warning" do |*args, &block|
          begin
            send("#{method_name}_without_warning", *args, &block)

          rescue Exception => e
            issue_warning(
              warning_source(method_name),
              view_path: ActsAsWarnable::Engine.root.join('app/views'),
              render: "acts_as_warnable/warnings/rescued_error",
              params: { error: e }
            )
            raise if options[:raise_anyway]
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

    def issue_warning(source, options_or_message)
      warning = warnings.create(source: source, message: options_or_message.inspect)

      case options_or_message
      when Hash
        opts = options_or_message.with_indifferent_access

        view_path = opts[:view_path] || Rails.configuration.paths["app/views"].first
        view      = opts[:view]   || opts[:template] || opts[:render]
        params    = opts[:params] || opts[:locals]   || {}

        view += ".md" unless view =~ /\.md$/

        message = WarningView.new(warning, self, view_path).render(template: view, locals: params)
      else
        message = options_or_message.to_s
      end

      warning.update_attributes! message: message

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
