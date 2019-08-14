require 'swagger_helper'

RSpec.describe 'email' do
  before :each do
    allow_any_instance_of(ApplicationController).to receive(:disable_jwt?).and_return(true)
  end

  path '/email' do
    post 'send an email' do
      consumes 'application/json'

      parameter name: :json, in: :body, required: true, schema: {
        type: :object,
        properties: {
          service_slug: { type: :string, required: true, example: 'my-form' },
          email: {
            type: :object,
            properties: {
              to: { type: :string, required: true, example: 'user@example.com' },
              subject: { type: :string, required: true, example: 'subject goes here' },
              body: { type: :string, required: true, example: 'body goes here' },
              template_name: { type: :string, required: true, example: 'email.generic' },
            }
          }
        }
      }

      response '201', 'email job created' do
        let(:json) do
          {
            service_slug: 'service-slug',
            email: {
              to: 'user@example.com',
              subject: 'subject goes here',
              body: 'body goes here',
              template_name: 'email.generic'
            }
          }
        end

        examples 'application/json' => {}

        run_test!
      end
    end
  end
end
