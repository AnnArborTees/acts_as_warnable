module ActsAsWarnable
  class WarningView < ActionView::Base
    # This class defines helpers that can be called within any warning
    # markdown template.

    def initialize(warning, object, path)
      @warning = warning
      @warnable = object

      lookup_context = ActionView::LookupContext.new(path)
      lookup_context.formats = [:md, :html]

      super(lookup_context, {}, nil, lookup_context.formats)

      unless object.nil?
        # Define a named accessor for the object,
        # e.g. a warning from an Order can call `order` within the view.
        define_singleton_method(object.class.name.underscore) { object }
      end
    end

    def object
      @warnable
    end

    def warning
      @warning
    end
  end
end
