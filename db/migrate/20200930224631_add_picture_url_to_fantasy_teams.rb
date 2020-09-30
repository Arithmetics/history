class AddPictureUrlToFantasyTeams < ActiveRecord::Migration[6.0]
  def change
    add_column :fantasy_teams, :picture_url, :string
  end
end
