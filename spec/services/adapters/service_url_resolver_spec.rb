require 'rails_helper'

describe Adapters::ServiceUrlResolver do
  let(:service_slug) { 'my-service' }
  let(:environment_slug) { 'dev' }

  subject { described_class.new(service_slug: service_slug, environment_slug: environment_slug) }

  describe '#resolve_uri_to_service' do
    context 'given a URI' do
      let(:uri){ URI.parse('/a/relative/path') }

      it 'sets the scheme to the scheme for the right environment from Rails config' do
        expect(subject.send(:resolve_uri_to_service, uri).scheme).to eq('https')
      end

      it 'sets the host to the service_slug.(env url_root from Rails config)' do
        expect(subject.send(:resolve_uri_to_service, uri).host).to eq('my-service.apps.cloud-platform-live-0.k8s.integration.dsd.io')
      end
    end
  end

  describe '#ensure_absolute_url' do
    context 'given an absolute URL' do
      let(:url) { 'https://www.example.com/' }

      it 'returns the given URL unmodified' do
        expect(subject.send(:ensure_absolute_url, url)).to eq(url)
      end
    end

    context 'given a relative URL' do
      let(:url) { '/a/relative/url' }
      before do
        allow(subject).to receive(:resolve_uri_to_service).and_return('an absolute URL')
      end

      it 'calls resolve_uri_to_service' do
        expect(subject).to receive(:resolve_uri_to_service).with(URI.parse(url))
        subject.send(:ensure_absolute_url, url)
      end

      it 'returns the resolved URL' do
        expect(subject.send(:ensure_absolute_url, url)).to eq('an absolute URL')
      end
    end
  end
end
