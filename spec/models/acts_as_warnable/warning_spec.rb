require 'rails_helper'

describe Warning do
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

  describe 'when a dismisser_id is assigned' do
    it 'sets dismissed_at to Time.now' do
      now = Time.now
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
