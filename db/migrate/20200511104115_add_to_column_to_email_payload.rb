class AddToColumnToEmailPayload < ActiveRecord::Migration[6.0]
  def change
    add_column :email_payloads, :to, :string
  end
end
