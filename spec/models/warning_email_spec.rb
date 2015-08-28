require 'rails_helper'

describe WarningEmail, story_822: true do
  subject { create :warning_email }

  describe 'Validations' do
    context 'model' do
      it 'is valid when it correspond to an actual model class' do
        subject.model = 'User'
        expect(subject).to be_valid
      end

      it 'is invalid when it does not correspond to any class' do
        subject.model = 'BadClassName'
        expect(subject).to_not be_valid
      end

      it 'is invalid when it correspond to a class that is not a model' do
        subject.model = 'Kernel'
        expect(subject).to_not be_valid
      end
    end
  end
end
