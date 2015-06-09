module ActsAsWarnable
  class WarningsController < ::ApplicationController
    before_filter :fetch_warning, only: [:update, :show]
    respond_to :html, :js

    helper do
      def method_missing(name, *args, &block)
        if main_app.respond_to?(name)
          main_app.send(name, *args, &block)
        else
          super
        end
      end
    end

    def index
      if params.key?(:warnable_id) && params.key?(:warnable_type)
        @warnings = Warning.where(warnable_id: params[:warnable_id], warnable_type: params[:warnable_type])

        @warnable = params[:warnable_type].constantize.find(params[:warnable_id])
        instance_variable_set('@'+params[:warnable_type].underscore, @warnable)

        warnables = params[:warnable_type].underscore.pluralize
        if lookup_context.exists?('warnings', warnables, false)
          render "#{warnables}/warnings"
        end
      else
        @warnings = Warning.all
      end

      @warnings = @warnings.active if params[:active_only]
    end

    def update
      was_dismissed = @warning.dismissed?
      if @warning.update_attributes(permitted_params[:warning])
        if !was_dismissed && @warning.dismissed?
          flash[:success] = "Warning dismissed"
        else
          flash[:success] = "Successfully updated warning"
        end
      else
        flash[:error] = "Failed to update warning: #{@warning.errors.full_messages.join(', ')}"
      end

      if params[:redirect_to]
        redirect_to params[:redirect_to]
      else
        redirect_to warnings_path
      end
    end

    def show
      render params[:render] if params.key?(:render)
    end

    protected

    def fetch_warning
      @warning = Warning.find(params[:id])
    end

    def permitted_params
      params.permit(
        warning: [
          :warnable_id, :warnable_type, :message, :dismissed_at, :dismisser_id
        ]
      )
    end
  end
end
