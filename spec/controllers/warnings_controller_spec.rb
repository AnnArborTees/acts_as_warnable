require 'rails_helper'

describe WarningsController do
  let(:warning) { create :warning }
  let(:other_warning) { create :warning }
  let(:test_object) { TestObject.create(name: 'bob') }

  describe 'GET #index' do
    context 'with warnable_id and warnable_type params' do
      before do
        other_warning
        test_object.warnings << warning
        get :index, warnable_id: test_object.id, warnable_type: test_object.class.name
      end

      it 'assigns @warnings to all of the warnings of the given warnable' do
        expect(assigns[:warnings]).to include warning
        expect(assigns[:warnings]).to_not include other_warning
      end
    end

    context 'without params' do
      before do
        other_warning
        warnings
        get :index
      end

      it 'assigns @warnings to all warnings' do
        expect(assigns[:warnings]).to include warning
        expect(assigns[:warnings]).to include other_warning
      end
    end
  end

  describe 'POST #create' do
    it 'creates a warning with the given params'
  end
end
