module ActsAsWarnable
  class WarningsController < ::ApplicationController
    before_filter :fetch_warning, only: [:update, :show]
    before_filter :populate_search_options, only: [:index]

    respond_to :html, :js

    helper ActsAsWarnable::Engine.helpers do
      def method_missing(name, *args, &block)
        if main_app.respond_to?(name)
          main_app.send(name, *args, &block)
        else
          super
        end
      end
    end

    def index
      search_warnings
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

    def populate_search_options
      @warning_sources = Warning.group(:source).map(&:source)
    end

    def search_warnings
      @warnings = Warning.all
      @warnings = @warnings.active if (params.key?(:active_only) && params[:active_only] == 'true')
      @warnings = @warnings.inactive if (params.key?(:active_only) && params[:active_only] == 'false')
      @warnings = @warnings.where(source: params[:source]) unless params[:source].blank?

      if params.key?(:warnable_id) && params.key?(:warnable_type)
        @warnings = @warnings.where(warnable_id: params[:warnable_id], warnable_type: params[:warnable_type])
        paginate_if_possible

        @warnable = params[:warnable_type].constantize.find(params[:warnable_id])
        instance_variable_set('@'+params[:warnable_type].underscore, @warnable)

        warnables = params[:warnable_type].underscore.pluralize
        if lookup_context.exists?('warnings', warnables, false)
          render "#{warnables}/warnings"
        end
      else
        paginate_if_possible
      end
    end

    def paginate_if_possible
      if Warning.column_names.include?('created_at')
        @warnings = @warnings.order('created_at desc')
      end
      @warnings = @warnings.page(params[:page] || 1) if @warnings.respond_to?(:page)
    end

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
