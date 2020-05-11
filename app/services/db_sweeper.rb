class DbSweeper
  def call
    vanquish_submissions
    annihilate_email_payloads
  end

  private

  def vanquish_submissions
    Submission.where('created_at < ?', submission_age_threshold).destroy_all
  end

  def annihilate_email_payloads
    EmailPayload.where('created_at < ?', email_payload_age_threshold)
                .where.not(succeeded_at: nil)
                .destroy_all
  end

  def submission_age_threshold
    28.days.ago
  end

  def email_payload_age_threshold
    7.days.ago
  end
end
