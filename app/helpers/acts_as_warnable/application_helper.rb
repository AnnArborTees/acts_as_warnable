module ActsAsWarnable
  module ApplicationHelper
    def current_devise_user
      begin
        send("current_#{Devise.mappings.values.first.name.to_s.underscore.singularize}")
      rescue NoMethodError => e
        current_user
      end
    end

    def button_to_dismiss_warning(warning, options = {})
      options[:class] ||= ''
      options[:class] += ' btn btn-warning'
      options[:text] ||= 'Dismiss'

      form_for(warning) do |f|
        f.hidden_field(:dismisser_id, value: current_devise_user.id) +
          hidden_field_tag(:redirect_to, request.fullpath) +
          button_tag(options.delete(:text), options)
      end
    end
  end
end
