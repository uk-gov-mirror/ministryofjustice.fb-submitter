class CreateSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :submissions, id: :uuid do |t|
      t.string          :status
      t.string          :service_slug
      t.string          :encrypted_user_id_and_token
      t.string          :submission_type
      t.json            :submission_details
      t.timestamps
    end
  end
end
