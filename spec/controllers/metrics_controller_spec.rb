require 'rails_helper'

RSpec.describe MetricsController do
  describe 'GET #show' do
    render_views

    let(:job) { Delayed::Job.create! }

    context 'with a pending job' do
      before do
        job.update!(attempts: 0)
        get :show, format: 'text'
      end

      it 'shows pending jobs' do
        expect(response.body).to include('# HELP delayed_jobs_pending Number of pending jobs')
        expect(response.body).to include('# TYPE delayed_jobs_failed gauge')
        expect(response.body).to include('delayed_jobs_pending 1')
      end
    end

    context 'when a failed job' do
      before do
        job.update!(attempts: 1)
        get :show, format: 'text'
      end

      it 'shows failed jobs' do
        expect(response.body).to include('# HELP delayed_jobs_failed Number of jobs failed')
        expect(response.body).to include('# TYPE delayed_jobs_failed gauge')
        expect(response.body).to include('delayed_jobs_failed 1')
      end
    end

    context 'with submissions' do
      before do
        Submission.create!(service_slug: 'form1')
        Submission.create!(service_slug: 'form1')
        Submission.create!(service_slug: 'form2')
      end

      it 'includes submissions per form' do
        get :show, format: 'text'

        expect(response.body).to include('# HELP submissions Number of submissions')
        expect(response.body).to include('# TYPE submissions counter')
        expect(response.body).to include('submissions{form="form1"} 2')
        expect(response.body).to include('submissions{form="form2"} 1')
      end
    end

    describe 'Response headers' do
      before { get :show, format: 'html' }

      it 'adds the prometheus version' do
        expect(response.headers['Content-Type']).to eq('text/plain; version=0.0.4')
      end
    end
  end
end
