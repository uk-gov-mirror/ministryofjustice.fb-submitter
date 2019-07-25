require 'rails_helper'

RSpec.describe MetricsController do
  describe 'GET #show' do
    render_views

    let(:job) { Delayed::Job.create! }

    context 'given a pending job' do
      before do
        job.update(attempts: 0)
        get :show, format: 'text'
      end

      it 'shows pending jobs' do
        expected_result = '# TYPE resque_jobs_pending gauge
# HELP resque_jobs_pending Number of pending jobs
resque_jobs_pending 1'
        expect(response.body).to include(expected_result)
      end
    end

    context 'given a failed job' do
      before do
        job.update(attempts: 1)
        get :show, format: 'text'
      end

      it 'shows failed jobs' do
        expected_result = '# TYPE resque_jobs_failed gauge
# HELP resque_jobs_failed Number of jobs failed
resque_jobs_failed 1'

        expect(response.body).to include(expected_result)
      end
    end

    describe 'Response headers' do
      before { get :show, format: 'text' }

      it 'adds the prometheus version' do
        expect(response.headers['version']).to eq('0.0.4')
      end
    end
  end
end
