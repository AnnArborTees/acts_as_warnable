require 'rails_helper'

describe ActsAsWarnable::Warning do
  subject { create :warning }
  let(:user) { create :user }

  context 'Relationships' do
    it { is_expected.to belong_to :warnable }
    # NOTE 'User' happens to be the devise mapping for the dummy app.
    # Warning will assign the class_name to the first devise mapping
    # class.
    it { is_expected.to belong_to(:dismisser).class_name('User') }
  end

  context 'Validations' do
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_presence_of(:source) }
  end

  describe '#record_occurrence!' do
    it 'bumps occurrences and refreshes last_issued_at atomically' do
      subject.update_columns(last_issued_at: 2.days.ago)

      subject.record_occurrence!

      expect(subject.occurrences).to eq 2
      expect(subject.last_issued_at).to be_within(5.seconds).of(Time.current)
      expect(subject.reload.occurrences).to eq 2
    end
  end

  describe '.merge_duplicates!' do
    let(:warnable) { TestObject.create(name: 'dupes') }
    let(:other_warnable) { TestObject.create(name: 'other') }

    # Writes dismissal columns directly, since assigning dismisser_id through
    # the model stamps dismissed_at with the current time.
    def make_warning(attrs = {})
      defaults = { warnable: warnable, source: 'src', message: 'same thing', created_at: 3.days.ago, last_issued_at: 3.days.ago }
      dismissal = attrs.extract!(:dismissed_at, :dismisser_id)
      ActsAsWarnable::Warning.create!(defaults.merge(attrs)).tap do |warning|
        warning.update_columns(dismissal) if dismissal.any?
      end
    end

    it 'collapses identical active warnings into the oldest, summing occurrences' do
      keeper = make_warning(occurrences: 2)
      make_warning(created_at: 2.days.ago, last_issued_at: 2.days.ago)
      make_warning(created_at: 1.day.ago, last_issued_at: 1.day.ago, occurrences: 3)

      stats = described_class.merge_duplicates!

      expect(stats).to eq(groups: 1, removed: 2)
      expect(described_class.count).to eq 1
      keeper.reload
      expect(keeper.occurrences).to eq 6
      expect(keeper.last_issued_at).to be_within(5.seconds).of(1.day.ago)
      expect(keeper).not_to be_dismissed
    end

    it 'treats a NULL occurrences value as 1' do
      keeper = make_warning
      make_warning(created_at: 2.days.ago).update_columns(occurrences: nil)

      described_class.merge_duplicates!

      expect(keeper.reload.occurrences).to eq 2
    end

    it 'leaves warnings that differ by source, message or warnable alone' do
      make_warning
      make_warning(source: 'other src')
      make_warning(message: 'different thing')
      make_warning(warnable: other_warnable)

      stats = described_class.merge_duplicates!

      expect(stats).to eq(groups: 0, removed: 0)
      expect(described_class.count).to eq 4
    end

    it 'keeps active and dismissed duplicates in separate groups' do
      active_one   = make_warning
      active_two   = make_warning(created_at: 2.days.ago)
      dismissed_a  = make_warning(dismissed_at: 2.days.ago, dismisser_id: user.id)
      dismissed_b  = make_warning(created_at: 2.days.ago, dismissed_at: 1.day.ago, dismisser_id: user.id)

      stats = described_class.merge_duplicates!

      expect(stats).to eq(groups: 2, removed: 2)
      expect(described_class.pluck(:id)).to match_array [active_one.id, dismissed_a.id]
      expect(active_one.reload.occurrences).to eq 2
      expect(dismissed_a.reload.occurrences).to eq 2
    end

    it 'gives a merged dismissed group the most recent dismissal' do
      keeper = make_warning(dismissed_at: 2.days.ago, dismisser_id: user.id)
      later_dismisser = create :user
      make_warning(created_at: 2.days.ago, dismissed_at: 1.day.ago, dismisser_id: later_dismisser.id)

      described_class.merge_duplicates!

      keeper.reload
      expect(keeper.dismissed_at).to be_within(5.seconds).of(1.day.ago)
      expect(keeper.dismisser_id).to eq later_dismisser.id
    end

    it 'does not fire dismissal activities while merging' do
      make_warning(dismissed_at: 2.days.ago, dismisser_id: user.id)
      make_warning(created_at: 2.days.ago, dismissed_at: 1.day.ago, dismisser_id: user.id)
      expect_any_instance_of(described_class).not_to receive(:fire_dismissal_activity)

      described_class.merge_duplicates!
    end

    it 'can be limited to a scope' do
      make_warning
      make_warning(created_at: 2.days.ago)
      make_warning(warnable: other_warnable)
      make_warning(warnable: other_warnable, created_at: 2.days.ago)

      stats = described_class.merge_duplicates!(scope: other_warnable.warnings)

      expect(stats).to eq(groups: 1, removed: 1)
      expect(warnable.warnings.count).to eq 2
      expect(other_warnable.warnings.count).to eq 1
    end
  end

  describe 'when a dismisser_id is assigned' do
    it 'sets dismissed_at to Time.now' do
      now = Time.now.change(usec: 0)
      allow(Time).to receive(:now).and_return now

      expect(subject.dismissed_at).to be_nil

      subject.dismisser_id = user.id
      subject.save!

      expect(subject.dismissed_at).to eq now
    end

    context 'when public activity is available and the warnable is tracked' do
      let(:test_warnable) { double('Warnable') }

      before do
        def test_warnable.create_activity(*args); end
        allow(subject).to receive(:warnable).and_return test_warnable
      end

      it 'creates an activity on save' do
        expect(test_warnable).to receive(:create_activity)
          .with(key: 'warning.dismiss', recipient: subject, owner: user)

        subject.dismisser_id = user.id
        subject.save!
      end
    end
  end
end
