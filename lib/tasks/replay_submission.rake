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
    if args[:submission_id].nil? || args[:jwt_skew_override].nil?
      puts 'Submission ID is required' if args[:submission_id].nil?
      puts 'JWT skew override is required' if args[:jwt_skew_override].nil?
    else
      old_job = Delayed::Job.all.find { |j| j.handler.include?(args[:submission_id]) }

      if old_job.nil?
        puts "No job for submission ID #{args[:submission_id]}"
      else
        Delayed::Job.enqueue(
          ProcessSubmissionService.new(
            submission_id: args[:submission_id],
            jwt_skew_override: args[:jwt_skew_override]
          )
        )
        puts "Queued new job for submission ID #{args[:submission_id]}"

        old_job.destroy!
        puts "Destroyed previous delayed job #{old_job.id}"
      end
    end
  end
end

namespace :replay_hmcts_adapter_submission do
  desc "
  Replay failed HMCTS submission
  Usage
  rake replay_hmcts_adapter_submission:process[<submission_id>]
  "
  task :process, [:submission_id] => :environment do |_t, args|
    if args[:submission_id].nil?
      puts 'At least one Submission ID is required'
    else
      submission = Submission.all.find do |s|
        s.decrypted_payload['meta']['submission_id'] == args[:submission_id]
      end

      if submission
        Delayed::Job.enqueue(
          ProcessSubmissionService.new(submission_id: submission.id)
        )
        puts "Queued new job for submission ID #{submission.id}"
      else
        puts "Unable to find matching Submission for ID #{args[:submission_id]}"
      end
    end
  end
end
