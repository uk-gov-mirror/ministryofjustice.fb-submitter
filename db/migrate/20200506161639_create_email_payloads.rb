class CreateEmailPayloads < ActiveRecord::Migration[6.0]
  def change
    create_table :email_payloads, id: :uuid do |t|
      t.string   :submission_id
      t.string   :attachments
      t.datetime :succeeded_at
      t.timestamps
    end
  end
end
