class AddSubmissionCompletionFields < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :completed_at, :datetime, nil: true
    add_column :submissions, :responses, :json, nil: true
  end
end
