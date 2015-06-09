require 'rails_helper'

describe ActsAsWarnable do
  describe 'a class that acts as warnable' do
    subject { TestObject.new }

    it { is_expected.to have_many(:warnings) }
    it { is_expected.to respond_to(:issue_warning) }
  end

  describe '.warn_on_failure_of' do
    before do
      TestObject.class_eval do
        def test_method
          raise "Oh, no!" if false != true
        end
        warn_on_failure_of :test_method
      end
    end
    subject { TestObject.create(name: 'jim') }

    context 'given the name of a method' do
      it 'wraps that method in a begin/rescue that issues a warning on rescue' do
        expect(subject.warnings.size).to eq 0
        expect{subject.test_method}.to_not raise_error
        expect(subject.warnings.size).to eq 1
        expect(subject.warnings.first.message).to include "Oh, no!"
      end
    end
  end

  describe '#issue_warning' do
    subject { TestObject.create(name: 'bill') }

    it 'creates a new warning with the given message' do
      subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!')
      expect(Warning.where(message: 'Oh snap!!')).to exist
    end

    context 'when the model is tracked by public activity' do
      it 'fires an activity with the key warning.issue' do
        def subject.create_activity(params);end
        expect(subject).to receive(:create_activity)
          .with(key: 'warning.issue', recipient: anything)

        subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!')
      end
    end
  end
end
