module ActsAsWarnable
  class WarningsController < ApplicationController
    before_filter :fetch_warning, only: [:update, :show]

    def index
      if params.key?(:warnable_id) && params.key?(:warnable_type)
        @warnings = Warning.where(warnable_id: params[:warnable_id], warnable_type: params[:warnable_type])
      else
        @warnings = Warning.all
      end
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
      render params[:render]
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
