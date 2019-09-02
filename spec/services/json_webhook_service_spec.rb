require 'rails_helper'

describe JsonWebhookService do
  let(:runner_callback_adaptor) do
    spy
  end

  let(:webhook_destnation_adaptor) do
    spy
  end

  subject do
    described_class.new(runner_callback_adaptor: runner_callback_adaptor, webhook_destnation_adaptor: webhook_destnation_adaptor)
  end

  it 'gets full submission from the frontend service' do
    subject.execute
    expect(runner_callback_adaptor)
      .to have_received(:fetch_full_submission)
      .with(url: 'example.com')
      .once
  end

  it 'posts to the given endpoint' do
    subject.execute
    expect(webhook_destnation_adaptor)
        .to have_received(:send_post)
                .with(url: 'example.com', body: {})
                .once
  end

  let(:response) {
    SecureRandom.uuid
  }

  it 'returns the response from the webhook_destnation_adaptor' do
    allow(webhook_destnation_adaptor).to receive(:send_post).and_return(response)
    expect(subject.execute).to eq(response)
  end
end
