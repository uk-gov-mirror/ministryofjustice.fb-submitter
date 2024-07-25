namespace :replay_submission do
  desc "
  Replay a submission
  Usage
  rake replay_submission:process[<submission_id>]
  "
  task :process, [:submission_id] => :environment do |_t, args|
    if args[:submission_id].nil?
      puts 'Submission ID is required'
    else
      job = Delayed::Job.all.find { |j| j.handler.include?(args[:submission_id]) }
      if job.nil?
        puts "No job for submission ID #{args[:submission_id]}"
      else
        job.update!(run_at: 10.seconds.from_now)
        puts "Replayed job for job ID #{job.id} - submission ID #{args[:submission_id]}"
      end
    end
  end

  desc "
  Replay a submission with attachments
  Usage
  rake replay_submission:with_attachments[<submission_id>,<jwt_skew_override>]
  "
  task :with_attachments, [:submission_id, :jwt_skew_override] => :environment do |_t, args|
    submission = Submission.find(args[:submission_id])

    if args[:submission_id].nil? || args[:jwt_skew_override].nil?
      puts 'Submission ID is required' if args[:submission_id].nil?
      puts 'JWT skew override is required' if args[:jwt_skew_override].nil?
    else
      old_job = Delayed::Job.all.find { |j| j.handler.include?(args[:submission_id]) }

      if old_job.nil?
        puts "No job for submission ID #{args[:submission_id]}"
      else
        V2::ProcessSubmissionJob.perform_later(
          submission_id: submission.id,
          jwt_skew_override: args[:jwt_skew_override]
        )

        puts "Queued new job for submission ID #{args[:submission_id]}"

        old_job.destroy!
        puts "Destroyed previous delayed job #{old_job.id}"
      end
    end
  end

  desc "
  Replay a batch of successful submissions for a given services within a date range
  Usage
  rake replay_submission:successful_batch[<date_from>,<date_to>,<service_slug>,<new_destination_email>]
  "
  task :successful_batch, [:date_from, :date_to, :service_slug, :new_destination_email] => :environment do |_t, args|
    # if args are nil
    if args[:date_from].nil? || args[:date_to].nil? || args[:service_slug].nil? || args[:new_destination_email].nil?
      puts 'Date from is required' if args[:date_from].nil?
      puts 'Date to is required' if args[:date_to].nil?
      puts 'Service slug is required' if args[:service_slug].nil?
      puts 'New destination email is required' if args[:new_destination_email].nil?
    else
      begin
        V2.ReplayBatchSubmission.new(
          date_from: args[:date_from],
          date_to: args[:date_to],
          service_slug: args[:service_slug],
          new_destination_email: args[:new_destination_email],
          resend_json: false,
          resend_mslist: false
        ).call
      rescue Date::Error
        puts 'Could not parse date input - enter a string that can be parsed using DateTime.parse'
      rescue StandardError => e
        puts e.message
      end
    end
  end
end
