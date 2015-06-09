require 'rails_helper'

describe ActsAsWarnable::WarningsController do
  routes { ActsAsWarnable::Engine.routes }

  let(:warning) { create :warning }
  let(:other_warning) { create :warning }
  let(:test_object) { TestObject.create(name: 'bob') }
  let(:user) { create :user }

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
        warning
        other_warning
        get :index
      end

      it 'assigns @warnings to all warnings' do
        expect(assigns[:warnings]).to include warning
        expect(assigns[:warnings]).to include other_warning
      end
    end
  end

  describe 'PUT #update' do
    let(:valid_params) do
      { message: 'Dear lord' }
    end
    let(:valid_dismissal_params) do
      { dismisser_id: user.id }
    end
    let(:invalid_params) do
      { message: '' }
    end

    context 'when the warning turns out to be a valid' do
      context 'change in message' do
        it 'updates the warning and sets the flash to "Successfully updated warning"' do
          put :update, id: warning.id, warning: valid_params
          expect(flash[:success]).to eq "Successfully updated warning"
          expect(warning.reload.message).to eq valid_params[:message]
        end
      end
      context 'dismissal' do
        it 'upates the warning and sets the flash to "Warning dismissed"' do
          put :update, id: warning.id, warning: valid_dismissal_params
          expect(flash[:success]).to eq "Warning dismissed"
          expect(warning.reload.dismisser_id).to eq user.id
        end
      end
    end

    context 'when the warning turns out invalid' do
      it 'displays an error in the flash' do
        put :update, id: warning.id, warning: invalid_params
        expect(flash[:error]).to include "blank"
        expect(warning.reload.message).to_not eq invalid_params[:message]
      end
    end
  end
end
