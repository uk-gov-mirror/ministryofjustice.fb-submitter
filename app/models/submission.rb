class Submission < ActiveRecord::Base
  include Concerns::HasStatusViaJob


  def unique_urls
    submission_details.to_a.map do |mail|
      mail.fetch('files')
    end.flatten.sort.uniq
  end

end
