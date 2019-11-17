json.purchases @purchases do |purchase|
  json.extract! purchase, :id, :price, :position, :year

  json.player do
    yearsStats = purchase.player.season_stats.select { |s| s.year == purchase.year }
    json.extract! purchase.player, :id, :name
    if yearsStats.length() == 1
      json.set! "rankReg", yearsStats[0].rank_reg
      json.set! "rankPpr", yearsStats[0].rank_ppr
    end
  end

  json.fantasy_team do
    json.extract! purchase.fantasy_team, :id, :name
  end

  json.owner do
    json.extract! purchase.fantasy_team.owner, :id, :name
  end
end
