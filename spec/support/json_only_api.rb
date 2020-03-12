RSpec.shared_context 'when a JSON-only API' do |method_name, url|
  describe 'a json request' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_token!)
    end

    context 'valid request' do
      let(:headers) do
        {
          'Content-type' => 'application/json'
        }
      end

      before do
        send(method_name, url, headers: headers)
      end

      it 'responds with the json content type' do
        expect(response.media_type).to eq('application/json')
      end

      it 'does not respond_with :not_acceptable' do
        expect(response.status).not_to eq(406)
      end
    end

    context 'invalid request' do
      let(:headers) do
        {
          'Content-type' => 'application/html'
        }
      end

      before do
        send(method_name, url, headers: headers)
      end

      it 'does responds_with :not_acceptable' do
        require 'pry'
        binding.pry
        expect(response.status).to eq(406)
      end
    end
  end
end
