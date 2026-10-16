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

      # Capture as locals: inside define_singleton_method, `self` is the view,
      # so referencing @warning there would read the view's (nil) ivar.
      warning  = @warning
      warnable = @warnable

      view.define_singleton_method(:warning) { warning }
      warnable_method_names(warnable).each do |name|
        view.define_singleton_method(name) { warnable }
      end

      view.render(
        template: template,
        formats: formats,
        locals: locals
      )
    end

    private

    # The warnable is exposed under its own class name and, for STI models,
    # its base class name too (so a SalesOrder < Order is available as `order`).
    def warnable_method_names(warnable)
      return [] if warnable.nil?

      klass = warnable.class
      base  = klass.respond_to?(:base_class) ? klass.base_class : klass

      [klass.name, base.name].compact.map(&:underscore).uniq
    end
  end
end
