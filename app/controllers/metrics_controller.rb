class MetricsController < ActionController::Base
  PrometheusResqueGauges = [
    { name: :resque_jobs_pending,
      lookup: :pending,
      docstring: 'Number of pending jobs' },
    { name: :resque_jobs_processed,
      lookup: :processed,
      docstring: 'Number of jobs processed' },
    { name: :resque_job_queues,
      lookup: :queues,
      docstring: ' Number of job queues' },
    { name: :resque_workers,
      lookup: :workers,
      docstring: 'Number of workers' },
    { name: :resque_workers_working,
      lookup: :working,
      docstring: 'Number of workers working' },
    { name: :resque_jobs_failed,
      lookup: :failed,
      docstring: 'Number of jobs failed' }
  ].freeze

  def show
    respond_to do |f|
      f.text
    end
  end

  private

  def prometheus_resque_gauges
    PrometheusResqueGauges
  end

  helper_method :prometheus_resque_gauges
end
