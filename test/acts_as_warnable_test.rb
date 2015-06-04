require 'test_helper'

class ActsAsWarnableTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, ActsAsWarnable
  end
end
