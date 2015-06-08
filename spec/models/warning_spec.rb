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
  end
end
