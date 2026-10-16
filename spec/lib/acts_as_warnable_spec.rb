require 'rails_helper'

describe ActsAsWarnable, type: :model do
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

    context 'passed raise_anyway: true' do
      before do
        TestObject.class_eval do
          def test_method
            raise "Oh, no!" if false != true
          end
          warn_on_failure_of :test_method, raise_anyway: true
        end
      end
      it 'issues the warning and re-raises the error' do
        expect(subject).to receive :issue_warning
        expect{subject.test_method}.to raise_error StandardError
      end
    end
  end

  describe '#issue_warning' do
    subject { TestObject.create(name: 'bill') }
    let(:user) { create :user }

    it 'creates a new warning with the given message' do
      subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!')
      expect(ActsAsWarnable::Warning.where(message: 'Oh snap!!')).to exist
    end

    it 'returns the warning with a single occurrence' do
      warning = subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!')

      expect(warning).to be_persisted
      expect(warning.occurrences).to eq 1
      expect(warning.last_issued_at).to be_present
      expect(warning).not_to be_reissued
    end

    context 'when an identical active warning already exists' do
      let!(:existing) { subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!') }

      it 'increments the existing warning instead of creating another' do
        travel_to(1.hour.from_now) do
          expect { subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!') }
            .not_to change { subject.warnings.count }
        end

        existing.reload
        expect(existing.occurrences).to eq 2
        expect(existing.last_issued_at).to be > existing.created_at
        expect(existing).to be_reissued
      end

      it 'returns the existing warning' do
        expect(subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!')).to eq existing
      end

      it 'does not fire a warning.issue activity for the repeat' do
        def subject.create_activity(params); end
        expect(subject).not_to receive(:create_activity)

        subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!')
      end

      it 'still creates a new warning when the source differs' do
        expect { subject.issue_warning('somewhere_else', 'Oh snap!!') }
          .to change { subject.warnings.count }.by(1)
        expect(existing.reload.occurrences).to eq 1
      end

      it 'still creates a new warning when the message differs' do
        expect { subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!!') }
          .to change { subject.warnings.count }.by(1)
      end

      it 'still creates a new warning on a different warnable' do
        other = TestObject.create(name: 'ted')
        expect { other.issue_warning('acts_as_warnable_spec', 'Oh snap!!') }
          .to change { ActsAsWarnable::Warning.count }.by(1)
        expect(existing.reload.occurrences).to eq 1
      end
    end

    context 'when the identical warning was dismissed' do
      let!(:dismissed) do
        subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!').tap { |w| w.dismiss(user) }
      end

      it 'creates a fresh warning with its own count' do
        reissued = nil
        expect { reissued = subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!') }
          .to change { subject.warnings.count }.by(1)

        expect(reissued).not_to eq dismissed
        expect(reissued.occurrences).to eq 1
        expect(reissued).not_to be_dismissed
        expect(dismissed.reload.occurrences).to eq 1
        expect(dismissed).to be_dismissed
      end

      it 'then counts further repeats against the fresh warning' do
        reissued = subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!')
        subject.issue_warning('acts_as_warnable_spec', 'Oh snap!!')

        expect(reissued.reload.occurrences).to eq 2
        expect(subject.warnings.count).to eq 2
      end
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
