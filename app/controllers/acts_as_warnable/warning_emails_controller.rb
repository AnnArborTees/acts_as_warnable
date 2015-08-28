module ActsAsWarnable
  class WarningEmailsController < ::InheritedResources::Base
    respond_to :html

    helper do
      def method_missing(name, *args, &block)
        if main_app.respond_to?(name)
          main_app.send(name, *args, &block)
        else
          super
        end
      end

      def warnable_classes
        ::ActiveRecord::Base.descendants.select do |c|
          c.reflect_on_all_associations.any? { |a| a.name == :warnings }
        end
      end
    end

    def show
      redirect_to action: :edit
    end

    protected

    def permitted_params
      params.permit(
        warning_email: [
          :model, :recipient, :minutes, :url
        ]
      )
    end
  end
end
