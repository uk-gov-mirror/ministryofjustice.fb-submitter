RSpec.shared_examples 'an authenticated method' do |method, url, payload|
  let(:basic_auth) {
    password = ENV['AUTH_BASIC_PASSWORD']
    raise unless password.present?
    ActionController::HttpAuthentication::Basic.encode_credentials('', password)
  }
  let(:body) { response.body }
  let(:parsed_body) {
    JSON.parse(response.body.to_s)
  }

  context 'with no auth header' do
    let(:headers) {
      {
        'content-type' => 'application/json'
      }
    }

    before do
      send method, url, params: payload, headers: headers
    end
    
    it 'has status 401' do
      expect(response).to have_http_status(401)
    end
  end

  context 'with an auth header' do
    before do
      send method, url, params: payload, headers: headers
    end

    let(:headers) do
      {
        'content-type' => 'application/json',
        'authorization' => basic_auth
      }
    end

    context 'which is valid' do
      it 'does not respond with an unauthorized or forbidden status' do
        expect(response).to_not have_http_status(401)
        expect(response).to_not have_http_status(403)
      end
    end

    context 'which is not valid' do
      let(:headers) do
        {
        'content-type' => 'application/json',
        'authorization' => 'invalid'
        }
      end

      context 'a request is made' do
        it 'has status 401' do
          expect(response).to have_http_status(401)
        end
      end
    end
  end

end
