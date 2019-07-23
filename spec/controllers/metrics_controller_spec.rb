require 'rails_helper'

RSpec.describe MetricsController do
  xdescribe 'GET #show' do
    render_views

    let(:info) do
      {
        pending: 1,
        processed: 2,
        queues: 3,
        workers: 4,
        working: 5,
        failed: 6
      }
    end

    before :each do
      allow(Resque).to receive(:info).and_return(info)
    end

    it 'works' do
      get :show, format: 'text'
      expect(response).to be_successful
    end

    it 'works' do
      get :show, format: 'html'
      expect(response).to be_successful
    end

    it 'returns prometheus metrics' do
      get :show, format: 'text'
      body = response.body

      expect(body).to include('# TYPE resque_jobs_pending gauge')
      expect(body).to include('# HELP resque_jobs_pending Number of pending jobs')
      expect(body).to include('resque_jobs_pending 1')
    end
  end
end
