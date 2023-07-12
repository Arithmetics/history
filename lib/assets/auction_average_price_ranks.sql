WITH historical_price as (WITH all_tagged AS (select purchases.position, price, ranking, purchases.year, purchases.player_id, name FROM purchases LEFT JOIN players ON purchases.player_id = players.id LEFT JOIN rankings ON players.id = rankings.player_id AND purchases.year = rankings.year) SELECT ranking, ROUND(AVG(price), 1) AS average_price, ROUND(MIN(price), 1) as min_price, ROUND(MAX(price),1) as max_price, position from all_tagged where position = 'QB' OR position = 'RB' OR position = 'WR' OR position = 'TE' group by ranking, POSITION ORDER BY position, ranking ASC NULLS LAST) SELECT historical_price.ranking, historical_price.average_price, historical_price.min_price, historical_price.max_price, historical_price.position, players.name, AGE(players.birthdate), season_stats.experience_at_season from historical_price left join rankings on historical_price.ranking = rankings.ranking AND historical_price.position = rankings.position left join players on players.id = rankings.player_id left outer join season_stats on players.id = season_stats.player_id where rankings.year = 2022 and (season_stats.year = 2021 OR season_stats.year is NULL);