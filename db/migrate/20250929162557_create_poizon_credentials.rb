class CreatePoizonCredentials < ActiveRecord::Migration[7.1]
  def change
    create_table :poizon_credentials do |t|
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
