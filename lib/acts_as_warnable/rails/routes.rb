module ActionDispatch
  class RouteSet
    class Mapper
      def warning_paths_for(*resources)
        resources.each do |resource|
          get "/#{resource.to_s.pluralize}/:warnable_id", defaults: { warnable_type: resource.singularize }
        end
      end
    end
  end
end
