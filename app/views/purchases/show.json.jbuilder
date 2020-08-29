json.purchases @purchases do |purchase|
  json.extract! purchase, :id, :price, :position, :year

  json.player do
    json.extract! purchase.player, :id, :name, :picture_id
  end

  json.fantasy_team do
    json.extract! purchase.fantasy_team, :id, :name
  end

  json.owner do
    json.extract! purchase.fantasy_team.owner, :id, :name
  end
end
