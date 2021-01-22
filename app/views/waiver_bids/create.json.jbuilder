json.bid do
  json.extract! @bid, :id, :amount, :year, :week, :winning
  json.player do
    json.extract! @bid.player, :id, :name, :picture_id
  end
  json.fantasy_team do 
    json.extract! @bid.fantasy_team, :id, :name, :picture_url
  end
end