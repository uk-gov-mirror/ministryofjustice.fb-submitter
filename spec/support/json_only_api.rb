RSpec.shared_context 'a JSON-only API' do |method_name, url|
  describe 'a json request' do
    let(:headers) {
      {
        'Content-type' => 'application/json'
      }
    }
    before do
      send(method_name, url, headers: headers)
    end

    it 'responds with the json content type' do
      expect(response.content_type).to eq('application/json')
    end

    it 'does not respond_with :unacceptable' do
      expect(response.status).to_not eq(:unacceptable)
    end
  end
end
