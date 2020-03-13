RSpec.shared_context 'when a JSON-only API' do |method_name, url|
  describe 'a json request' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_token!) # rubocop:disable RSpec/AnyInstance
    end

    context 'with a application/json media format' do
      before do
        send(method_name, url, headers: { 'ACCEPT' => 'application/json' })
      end

      it 'responds with the json content type' do
        expect(response.media_type).to eq('application/json')
      end

      it 'does not respond_with :not_acceptable' do
        expect(response.status).not_to eq(406)
      end
    end

    context 'when the request is not a json type' do
      it 'does responds_with :not_acceptable' do
        send(method_name, url, headers: { 'Content-Type' => 'application/html' })
        expect(response.status).to eq(406)
      end
    end
  end
end
