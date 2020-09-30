json.purchases @purchases do |purchase|
  json.extract! purchase, :id, :price, :position, :year

  json.player do
    years_stats = purchase.player.season_stats.select { |s| s.year == purchase.year }
    years_preseason_ranks = purchase.player.rankings.select { |r| r.year == purchase.year }
    json.extract! purchase.player, :id, :name, :picture_id
    if years_stats.length() == 1
      json.set! "rankReg", years_stats[0].rank_reg
      json.set! "rankPpr", years_stats[0].rank_ppr
    end
    if years_preseason_ranks.length() == 1
      json.set! "preSeasonRank", years_preseason_ranks[0].ranking
    end
  end

  json.fantasy_team do
    json.extract! purchase.fantasy_team, :id, :name, :picture_url
  end

  json.owner do
    json.extract! purchase.fantasy_team.owner, :id, :name
  end
end
