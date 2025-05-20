require 'acts_as_warnable/version'
require 'acts_as_warnable/engine'
require 'acts_as_warnable/rails/routes'
require 'acts_as_warnable/warning_view'

module ActsAsWarnable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_warnable(options = {})
      has_many :warnings, as: :warnable, class_name: 'ActsAsWarnable::Warning'
      include WarnableInstanceMethods
      extend WarnableClassMethods
    end
  end

  def self.inspect_error(e)
    result = {}

    # Inspect the response of ActiveResource and RestClient errors
    if (response = e.try(:response))
      if (code = response.try(:code) and message = response.try(:message))
        result[:code] = "#{code} #{message}"
      end

      if (body = response.try(:body))
        result[:response] = body
      end
    end

    result.with_indifferent_access
  end

  module WarnableClassMethods
    def remove_warning_modules
      @@warning_modules.try(:each) do |mod|
        mod.instance_methods.each { |m| mod.send(:undef_method, m) }
      end
    end

    def warn_on_failure_of(*methods)
      options = methods.last.is_a?(Hash) ? methods.pop : {}

      methods.each do |method_name|
        original_method = instance_method(method_name)

        method_without_warning = proc do |*args, &block|
          original_method.bind(self).call(*args, &block)
        end

        method_with_warning = proc do |*args, &block|
          begin
            original_method.bind(self).call(*args, &block)
          rescue Exception => e
            issue_error_warning(e, warning_source(method_name.inspect))
            raise if options[:raise_anyway]
          end
        end

        define_method("#{method_name}_without_warning", &method_without_warning)
        define_method("#{method_name}_with_warning", &method_with_warning)
        define_method(method_name, &method_with_warning)
      end
    end
  end

  module WarnableInstanceMethods
    def issue_error_warning(error, source = "Miscellaneous Error")
      begin
        Sentry.capture_exception(error) 
      rescue NameError
      end
      
      issue_warning(
        source,
        view_path: ActsAsWarnable::Engine.root.join('app/views'),
        render: "acts_as_warnable/warnings/rescued_error",
        params: { error: error, inspection: ActsAsWarnable.inspect_error(error) }
      )
    end

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

        # Determine format based on extension
        format =
          case view
          when /\.(html)$/ then :html
          when /\.(haml)$/ then :haml
          when /\.(slim)$/ then :slim
          else :md
          end
        
        # Strip known extensions (e.g., .md.erb, .html.erb, .haml, etc.)
        view = view.sub(/\.(md|html)?\.(erb|haml|slim)$/, '').sub(/\.(erb|haml|slim|html|md)$/, '')

        # Render using format and cleaned view name
        message = WarningView.new(warning, self, view_path).render(
          template: view,
          locals: params,
          formats: [format]
        )
      else
        message = options_or_message.to_s
      end

      warning.update! message: message

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
