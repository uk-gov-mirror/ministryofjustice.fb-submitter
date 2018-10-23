class Submission < ActiveRecord::Base
  include Concerns::HasStatusViaJob

  # returns an array of value objects of class (submission_type)
  def detail_objects
    submission_details.to_a.map do |detail|
      details_class(detail).new(detail.merge(submission: self))
    end
  end

  def details_class(detail)
    [detail['type'] || detail[:type], 'submission', 'detail'].join('_').classify.constantize
  end
end
