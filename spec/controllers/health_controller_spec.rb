require 'rails_helper'

describe HealthController do
  describe 'GET #show' do
    it 'returns 200 OK' do
      get :show
      expect(response.body).to eq('healthy')
      expect(response.status).to eq(200)
    end
  end
end
