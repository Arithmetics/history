json.fantasy_teams @fantasy_teams do |fantasy_team|
  json.extract! fantasy_team, :id, :name, :year

  json.owner fantasy_team.owner, partial: "owners/owner", as: :owner
end
