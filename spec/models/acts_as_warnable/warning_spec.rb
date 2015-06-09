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
  end
end
