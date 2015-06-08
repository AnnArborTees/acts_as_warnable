class WarningsController < ActsAsWarnable::ApplicationController
  before_filter :fetch_warning, only: :create

  def index
    if params.key?(:warnable_id) && params.key?(:warnable_type)
      @warnings = Warning.where(warnable_id: params[:warnable_id], warnable_type: params[:warnable_type])
    else
      @warnings = Warning.all
    end
  end

  def create
    if @warning.update_attributes(permitted_params[:warning])
      # params[:then] ?
    else
      # Render?
    end
    raise "WHAT TO DO"
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
