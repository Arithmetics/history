json.owners @owners do |owner|
  json.extract! owner, :id, :name

  json.fantasy_teams owner.fantasy_teams do |fantasy_team|
    json.extract! fantasy_team, :id, :name, :year
  end
end
