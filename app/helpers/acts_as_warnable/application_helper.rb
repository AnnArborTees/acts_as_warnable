module ActsAsWarnable
  module ApplicationHelper
    def current_devise_user
      send("current_#{Devise.mappings.values.first.name.to_s.underscore.singularize}")
    end

    def button_to_dismiss_warning(warning, options = {})
      form_for(warning, options) do |f|
        f.hidden_field(:dismisser_id, value: current_devise_user.id) +
          hidden_field_tag(:redirect_to, request.fullpath) +
          f.submit('Dismiss', class: 'btn btn-warning')
      end
    end
  end
end
