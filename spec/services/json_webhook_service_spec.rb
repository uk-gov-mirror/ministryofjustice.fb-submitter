require 'rails_helper'

describe JsonWebhookService do
  let(:runner_callback_adapter) do
    instance_double(Adapters::RunnerCallback)
  end

  let(:webhook_destination_adapter) do
    instance_double(Adapters::WebhookDestination)
  end

  subject do
    described_class.new(runner_callback_adapter: runner_callback_adapter, webhook_destination_adapter: webhook_destination_adapter)
  end


  let(:response) do
    SecureRandom.uuid
  end

  it 'gets full submission from the frontend service' do
    allow(webhook_destination_adapter).to receive(:send_webhook)

    expect(runner_callback_adapter).to receive(:fetch_full_submission)
    subject.execute
  end

  it 'posts to the given endpoint' do
    allow(runner_callback_adapter).to receive(:fetch_full_submission)

    expect(webhook_destination_adapter)
      .to receive(:send_webhook)
      .once
    subject.execute
  end

  let(:frontend_responce) do
    { id: SecureRandom.uuid }
  end

  it 'sends the webhook destination return to the destination' do
    expect(runner_callback_adapter).to receive(:fetch_full_submission).and_return(frontend_responce)

    expect(webhook_destination_adapter).to receive(:send_webhook)
      .with(body: frontend_responce)
      .once

    subject.execute
  end
end
