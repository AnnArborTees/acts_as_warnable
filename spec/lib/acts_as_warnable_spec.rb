require 'rails_helper'

describe ActsAsWarnable do
  describe 'a class that acts as warnable' do
    subject { TestObject.new }

    it { is_expected.to have_many(:warnings) }
    it { is_expected.to respond_to(:issue_warning) }
  end
end
