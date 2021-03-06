Acts as Warnable
===============

Here's a gem that'll let you attach warnings to your models to track when
tasks fail.

Installation
------------

Add to your gemfile:
```ruby
gem 'acts_as_warnable', github: 'AnnArborTees/acts_as_warnable'
```
and run
    bundle install

Next, run
```bash
rails generate acts_as_warnable:warning
```
to generate the migration for the warning model. Don't forget to
`rake db:migrate`.

In your routes.rb:
```ruby
mount ActsAsWarnable::Engine => '/'
```

In application.js:
```javascript
//...
//= require showdown/showdown.js
//= require acts_as_warnable/warning_markdown.js
```

In application.css:
```css
/*...
 *= require acts_as_warnable/markdown_style
 */
```

Use
---

As you may have guessed, you can call `acts_as_warnable` in your ActiveRecord
class definitions, like so:
```ruby
class TestObject < ActiveRecord::Base
  acts_as_warnable
end
```

This gives TestObject a `has_many :warnings, as: :warnable` relationship as well
as access to a few handy methods.

It also gives it access to a few instance methods, like `issue_warning(source, message)`:

```ruby
class TestObject < ActiveRecord::Base
  acts_as_warnable

  def do_stuff(something)
    # ...
    if something_bad_happened
      issue_warning('Test Object doing stuff', 'Something bad happened!!')
    end
    # OR
    if something_else_bad_happened
      issue_warning(
        'Test Object doing stuff',

        render: "test_objects/warning.md",
        locals: { anything: something }
      )
    end
  end
end
```

This pretty much just creates a warning. However, if you have
[Public Activity](https://github.com/chaps-io/public_activity) and your model is also
`tracked`, `issue_warning` will create an activity with your model as the trackable,
the warning as the recipient, and under the key "warning.issue".

Warnings have a source and a message. The source should be where the warning came
from, and the message should describe what went wrong - often a rescued error message.
Since that seems like a fairly common use for this gem, we provide a helper method
to simplify it further:

```ruby
class TestObject < ActiveRecord::Base
  acts_as_warnable

  def important_task(important_input)
    important_input.do_something_that_might_raise_an_error
  end
  warn_on_failure_of :important_task
end
```

Now, if `important_task` ever raises an error, it will issue a warning with a source
of "TestObject#important_task" and the message will be
"&lt;error class&gt;: &lt;error message&gt; &lt;backtrace&gt;".
Since warn_on_failure_of will be catching the error, it won't get raised. That might not be a problem,
but if you'd rather the error get re-thrown, you can do this:

```ruby
warn_on_failure_of :important_task, raise_anyway: true
```

### Dismissal

Warnings can also be "dismissed" by users of your app. As of right now, ActsAsWarnable
depends on [Devise](https://github.com/plataformatec/devise), and the warning dismisser_id refers to the first Devise mapping in
your app. This is not the best style and can certainly be more extensible, but it fits
our purposes just fine for now (feel free to change it and pull request if it doesn't fit yours).

A view helper is provided: `button_to_dismiss_warning(warning)`. When clicked, the warning
will be dismissed, which sets the dismisser_id to the user id, and dismissed_at to the time
of dismissal. You can filter out dismissed warnings with the `Warning.active` scope.
Dismissal also generates a [Public Activity](https://github.com/chaps-io/public_activity)
activity (if applicable) with a key of "warning.dismiss".

There are also route helpers. In your config/routes.rb:
```ruby
resources :my_models # <- not necessary, just for example's sake
warning_paths_for :my_models
```

That will give you access to `my_model_warnings_path(some_instance_of_my_model.id)`.
There is a default index.html.erb for warnings, but if you want one specific to your
model, you can create `app/views/my_model/warnings.html.erb` and that will be rendered
instead. Within that view, you will have access to `@warnings` and `@my_model`.

### Warning Emails

If you're interested in receiving notifications when there are warnings on a certain model,
you can configure warning emails by visiting `<acts_as_warnable root>/warning_emails`. Additionally,
to have the app actually send emails, run:
    rails generate acts_as_warnable:email_thread
