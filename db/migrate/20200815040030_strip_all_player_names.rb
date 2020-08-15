class StripAllPlayerNames < ActiveRecord::Migration[6.0]
  def change
    Player.all.each do |player|
      new_name = player.name.gsub(/\A\p{Space}*|\p{Space}*\z/, "")
      player.update!(name: new_name)
    end
  end
end
