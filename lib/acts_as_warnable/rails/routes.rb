module ActionDispatch
  module Routing
    class Mapper
      def warning_paths_for(*resources)
        resources.map(&:to_s).each do |resource|
          get "/#{resource.pluralize}/:warnable_id/warnings",
              to: 'warnings#index',
              defaults: { warnable_type: resource.singularize.camelize },
              as: "#{resource.singularize}_warnings"

          post "/#{resource.pluralize}/:warnable_id/warnings",
               to: 'warnings#post',
               defaults: { warnable_type: resource.singularize.camelize }
        end
      end
    end
  end
end
