module ActsAsWarnable
  class WarningView
    # This class defines helpers that can be called within any warning markdown template.

    def initialize(warning, object, path)
      @warning = warning
      @warnable = object
      @view_path = path
    end

   def render(template:, locals: {}, formats: [:md, :html])
      lookup_context = ActionView::LookupContext.new(@view_path)
      lookup_context.formats = formats
    
      view_class = Class.new(ActionView::Base.with_empty_template_cache.with_view_paths(@view_path))
    
      # Add dynamic methods to the instance
      view = view_class.new
      view.define_singleton_method(:warning) { @warning }
      view.define_singleton_method(@warnable.class.name.underscore) { @warnable } if @warnable
    
      view.render(template: template, formats: formats, locals: locals)
    end
  end
end
