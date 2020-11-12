namespace :replay_submissions do
  desc "
  Replay submissions
  For more than one submission ID use space separated IDs
  Usage
  rake replay_submissions:process[<submission_ids>]
  "
  task :process, [:submission_ids] => :environment do |_t, args|
    if args[:submission_ids].nil?
      puts 'At least one Submission ID is required'
    else
      submission_ids = args[:submission_ids].split(' ')
      submission_ids.each do |submission_id|
        job = Delayed::Job.all.find { |j| j.handler.include?(submission_id) }
        if job.nil?
          puts "No job for submission ID #{submission_id}"
        else
          job.update!(run_at: 10.seconds.from_now)
          puts "Replayed job for job ID #{job.id} - submission ID #{submission_id}"
        end
      end
    end
  end

  desc "
  Replay submissions with attachments
  For more than one submission ID use space separated IDs
  Usage
  rake replay_submissions:with_attachments[<submission_ids>,<jwt_skew_override>]
  "
  task :with_attachments, [:submission_ids, :jwt_skew_override] => :environment do |_t, args|
    if args[:submission_ids].nil? || args[:jwt_skew_override].nil?
      puts 'At least one Submission ID is required' if args[:submission_ids].nil?
      puts 'JWT skew override is required' if args[:jwt_skew_override].nil?
    else
      submission_ids = args[:submission_ids].split(' ')
      submission_ids.each do |submission_id|
        old_job = Delayed::Job.all.find { |j| j.handler.include?(submission_id) }

        if old_job.nil?
          puts "No job for submission ID #{submission_id}"
        else
          Delayed::Job.enqueue(
            ProcessSubmissionService.new(
              submission_id: submission_id,
              jwt_skew_override: args[:jwt_skew_override]
            )
          )
          puts "Queued new job for submission ID #{submission_id}"

          old_job.destroy!
          puts "Destroyed previous delayed job #{old_job.id}"
        end
      end
    end
  end
end

namespace :replay_hmcts_adapter_submissions do
  desc "
  Replay failed HMCTS submissions
  For more than one submission ID use space separated IDs
  Usage
  rake replay_hmcts_adapter_submissions:process[<submission_ids>]
  "
  task :process, [:submission_ids] => :environment do |_t, args|
    if args[:submission_ids].nil?
      puts 'At least one Submission ID is required'
    else
      payload_submission_ids = args[:submission_ids].split(' ')
      submissions = Submission.all.select do |s|
        s.decrypted_payload['meta']['submission_id'].in?(payload_submission_ids)
      end

      submissions.each do |submission|
        Delayed::Job.enqueue(
          ProcessSubmissionService.new(submission_id: submission.id)
        )
        puts "Queued new job for submission ID #{submission.id}"
      end
    end
  end
end
