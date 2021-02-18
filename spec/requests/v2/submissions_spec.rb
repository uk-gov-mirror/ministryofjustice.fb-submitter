require 'rails_helper'
require 'webmock/rspec'

describe 'V2 Submissions endpoint', type: :request do
  describe 'a POST request' do
    let(:access_token) { 'an-jwt-access-token' }
    let(:headers) do
      {
        'Content-type' => 'application/json',
        'Accept' => 'application/json',
        'Authorization': "Bearer #{access_token}"
      }
    end
    let(:service_slug) { 'mos-eisley' }
    let(:url) { '/v2/submissions' }
    let(:pdf_file_content) { 'apology accepted, captain needa' }
    let(:post_request) { post url, params: params.to_json, headers: headers }
    let(:submission_decryption_key) { SecureRandom.uuid[0..31] }

    before do
      Delayed::Worker.delay_jobs = false

      stub_request(
        :get,
        'http://fake_service_token_cache_root_url/service/mos-eisley'
      ).to_return(status: 200, body: { token: '123' }.to_json)
      stub_request(
        :post,
        'http://pdf-generator.com/v1/pdfs'
      ).to_return(status: 200, body: pdf_file_content)
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[])
        .with('SUBMISSION_DECRYPTION_KEY')
        .and_return(submission_decryption_key)
    end

    after do
      Delayed::Worker.delay_jobs = true
    end

    include_context 'when a JSON-only API', :post, '/v2/submissions'

    context 'with a valid token' do
      before do
        allow_any_instance_of(Fb::Jwt::Auth).to receive(:verify!).and_return(true)
      end

      let(:valid_submission_payload) do
        JSON.parse(
          File.read(
            Rails.root.join('spec', 'fixtures', 'payloads', 'valid_submission.json')
          )
        )
      end

      context 'with valid submission payload' do
        let(:params) do
          {
            encrypted_submission: SubmissionEncryption.new(
              key: submission_decryption_key
            ).encrypt(valid_submission_payload)
          }
        end

        it 'returns status 201' do
          post_request
          expect(response).to have_http_status(:created)
        end

        it 'creates a submission record' do
          expect { post_request }.to change(Submission, :count).by(1)
        end

        it 'encrypts the submission in the database' do
          post_request
          submission = Submission.last
          expect(submission.try(:payload)).to_not be_nil
          expect(submission.decrypted_submission).to eq(
            valid_submission_payload
          )
        end

        it 'saves the submission access token' do
          post_request
          submission = Submission.last
          expect(submission.try(:access_token)).to eq(access_token)
        end

        it 'creates a V2 Job to be processed asynchronously' do
          expect(V2::ProcessSubmissionJob).to receive(:perform_later)
          post_request
        end
      end

      context 'with invalid submission payload' do
        context 'missing encrypted_submission' do
          it 'validates the submission payload against the schema' do
          end
        end

        context 'additional properties in payload' do
        end

        context 'invalid encrypted submission' do
          it 'validates the submission payload against the schema' do
          end
        end
      end
    end

    context 'with invalid token' do
      let(:response_body) { JSON.parse(response.body) }
      let(:params) { {} }

      context 'when token not present' do
        before do
          allow_any_instance_of(Fb::Jwt::Auth).to receive(:verify!).and_raise(
            Fb::Jwt::Auth::TokenNotPresentError, 'Token is not present'
          )
          post_request
        end

        it 'returns forbidden' do
          expect(response.status).to be(403)
        end

        it 'returns response body' do
          expect(response_body).to eq('message' => ['Token is not present'])
        end
      end

      context 'when application not present ' do
        before do
          allow_any_instance_of(Fb::Jwt::Auth).to receive(:verify!).and_raise(
            Fb::Jwt::Auth::IssuerNotPresentError, 'Issuer is not present'
          )
          post_request
        end

        it 'returns forbidden' do
          expect(response.status).to be(403)
        end

        it 'returns response body' do
          expect(response_body).to eq('message' => ['Issuer is not present'])
        end
      end

      context 'when namespace not present' do
        before do
          allow_any_instance_of(Fb::Jwt::Auth).to receive(:verify!).and_raise(
            Fb::Jwt::Auth::NamespaceNotPresentError, 'Namespace is not present'
          )
          post_request
        end

        it 'returns forbidden' do
          expect(response.status).to be(403)
        end

        it 'returns response body' do
          expect(response_body).to eq('message' => ['Namespace is not present'])
        end
      end

      context 'when token is not valid' do
        before do
          allow_any_instance_of(Fb::Jwt::Auth).to receive(:verify!).and_raise(
            Fb::Jwt::Auth::TokenNotValidError, 'Token is not valid'
          )
          post_request
        end

        it 'returns forbidden' do
          expect(response.status).to be(403)
        end

        it 'returns response body' do
          expect(response_body).to eq('message' => ['Token is not valid'])
        end
      end

      context 'when token is expired' do
        before do
          allow_any_instance_of(Fb::Jwt::Auth).to receive(:verify!).and_raise(
            Fb::Jwt::Auth::TokenExpiredError, 'Token has expired'
          )
          post_request
        end

        it 'returns forbidden' do
          expect(response.status).to be(403)
        end

        it 'returns response body' do
          expect(response_body).to eq('message' => ['Token has expired'])
        end
      end
    end
  end
end
