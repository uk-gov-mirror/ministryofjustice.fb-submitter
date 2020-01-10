class AddAccessTokenToSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :access_token, :text
  end
end
