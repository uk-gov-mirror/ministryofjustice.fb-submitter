require 'rails_helper'

describe 'UserData API', type: :request do
  let(:headers) {
    {
      'Content-type' => 'application/json'
    }
  }
  let(:service_slug) { 'my-service' }
  # NOTE: this must be a valid UUID, otherwise ActiveRecord silently
  # ignores it in an initializer
  let(:user_identifier) { SecureRandom::uuid }


  describe 'a POST request' do
    describe 'to /submission' do
      let(:url) { "/submission" }
      let(:post_request) do
        post url, params: params.to_json, headers: headers
      end

      it_behaves_like 'a JSON-only API', :post, '/submission'
      it_behaves_like 'a JWT-authenticated method', :post, '/submission', {}

      context 'with a valid token' do
        before do
          allow_any_instance_of(ApplicationController).to receive(:verify_token!)
        end

        context 'and a valid JSON body' do
          let(:encrypted_user_id_and_token) { 'kdjh9s8db9s87dbosd7b0sd8b70s9d8bs98d7b9s8db' }
          let(:params) do
            {
            	service_slug: service_slug,
            	encrypted_user_id_and_token: encrypted_user_id_and_token,
            	submission_type: "email",
            	submission_details: [
            		{
            			destination: "destination@example.com",
            			files: [
            				"relative_url_1",
            				"relative_url_2"
                  ]
                }
              ]
            }
          end


          context 'when the request is successful' do
            before do
              allow(ProcessSubmissionJob).to receive(:perform_later)
            end

            it 'creates a submission record' do
              expect{ post_request }.to change(Submission, :count).by(1)
            end

            describe 'the created Submission record' do
              let(:created_record) { Submission.last }

              it 'has status "queued"' do
                post_request
                expect(created_record.status).to eq('queued')
              end

              it 'has submission_type "email"' do
                post_request
                expect(created_record.submission_type).to eq('email')
              end
            end

            it 'puts a ProcessSubmissionJob on the queue for the submission id' do
              post_request
              expect(ProcessSubmissionJob).to have_received(:perform_later).with(submission_id: Submission.last.id)
            end

            describe 'the response' do
              before do
                post_request
              end
              it 'has status 201' do
                expect(response).to have_http_status(201)
              end

              describe 'the body' do
                it 'is a valid JSON packet' do
                  expect{JSON.parse(body)}.to_not raise_error
                end

                it 'is the new Submission record, serialised to JSON' do
                  expect(body).to eq(Submission.last.to_json)
                end
              end
            end
          end
        end
      end
    end
  end
end
