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

      view = ActionView::Base.with_view_paths(@view_path).new(lookup_context, locals, nil)
      view.view_renderer = ActionView::Renderer.new(lookup_context)

      if @warnable
        method_name = @warnable.class.name.underscore
        view.define_singleton_method(method_name) { @warnable }
      end

      view.define_singleton_method(:warning) { @warning }

      view.render(template: template, formats: formats, locals: locals)
    end
  end
end
