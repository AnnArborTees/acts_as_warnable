module ActsAsWarnable
  class WarningView
    def initialize(warning, object, path)
      @warning = warning
      @warnable = object
      @view_path = path
    end

    def render(template:, locals: {}, formats: [:md])
      lookup_context = ActionView::LookupContext.new(@view_path)
      lookup_context.formats = formats
    
      view = ActionView::Base.with_empty_template_cache.with_view_paths(@view_path)
    
      view.define_singleton_method(:warning) { @warning }
      if @warnable
        view.define_singleton_method(@warnable.class.name.underscore) { @warnable }
      end
    
      view.render(
        template: template,
        formats: formats,
        locals: locals
      )
    end
  end
end
