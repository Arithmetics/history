

def player_stat_update()
  begin
    ActiveRecord::Base.transaction do
      Player.all.each do |player|
        puts "INVESTIGATION on #{player.name}"
        all_games = get_all_player_games(player.id)
        all_games = all_games.sort().to_h
        all_games.each do |year, games|
          if year > 2010
            found_count = games.length
            db_count = 0
            db_season = player.season_stats.where(year: year).first
            if db_season != nil
              db_count = db_season.games_played
            end
            if db_count != found_count
              if db_season != nil
                puts "deleting season for #{db_season.player.name}, year: #{db_season.year}, games played: #{db_season.games_played}"
                db_season.delete!
              end
              update_season_stats(player, db_season, games)
            end
          end
        end
      end
      finish_season_stats()
    end
  end
end

def update_season_stats(player, db_season, years_games)
  if db_season == nil
    db_season = SeasonStat.new(player: player)
  end
  total_season_stats = {}
  years_games.each do |game|
    if total_season_stats[:games_played] == nil
      total_season_stats[:games_played] = 1
    else
      total_season_stats[:games_played] += 1
    end
    game.each_key do |key|
      if total_season_stats[key] == nil || key == :position || key == :year || key == :week || key == :id
        total_season_stats[key] = game[key]
      else
        total_season_stats[key] += game[key]
      end
    end
  end
  total_season_stats.delete(:week)
  total_season_stats.delete(:id)

  total_season_stats.each do |stat, value|
    db_season[stat] = value
  end

  season_start = Date.parse("#{total_season_stats[:year]}-09-01")
  birthdate = player.birthdate
  db_season.age_at_season = ((season_start - birthdate) / 365).to_f.round(2)

  puts "new db season found for: #{db_season.player.name}, year: #{db_season.year}, games_played: #{db_season.games_played}"
  db_season.save!
end

def get_all_player_games(player_id)
  begin
    doc = Nokogiri::HTML(open("http://www.nfl.com/player/drewbrees/#{player_id}/gamelogs"))
  rescue OpenURI::HTTPError => ex
    throw "could not find player #{player_id}"
  end
  all_player_games = {}
  get_seasons_played(doc).each do |option|
    year = option.text
    all_player_games[year] = []
    doc = Nokogiri::HTML(open("http://www.nfl.com/player/drewbrees/#{player_id}/gamelogs?season=#{year}"))
    position = get_players_position(doc)
    game_tables = doc.css(".data-table1")
    game_tables.each do |table|
      type = table.css(".player-table-header").css("td")[0].text
      if type == "Regular Season"
        game_row = table.css("tr")
        game_row.each do |row|
          cells = row.css("td")
          if is_a_legit_row?(cells)
            if position == "QB"
              all_player_games[year].push(get_qb_game(cells, player_id, year))
            elsif position == "RB"
              all_player_games[year].push(get_rb_game(cells, player_id, year))
            elsif position == "WR"
              all_player_games[year].push(get_wr_game(cells, player_id, year))
            elsif position == "TE"
              all_player_games[year].push(get_te_game(cells, player_id, year))
            elsif position == "WR/TE"
              all_player_games[year].push(get_wr_te_game(cells, player_id, year))
            end
          end
        end
      end
    end
  end
  return all_player_games
end

def get_seasons_played(doc)
  season_options = []
  doc.css("#season").css("option").each do |option|
    season_options.push(option.attr("value"))
  end
end

def type_game(game)
  game.each do |k, v|
    if v == "--"
      v = "0"
    end
    if k != :position
      game[k] = v.to_i
    end
  end
  return game
end

def get_qb_game(cells, id, year)
  new_game = { id: id, year: year }
  new_game[:week] = cells[0].text
  new_game[:position] = "QB"

  new_game[:passing_completions] = cells[6].text
  new_game[:passing_attempts] = cells[7].text
  new_game[:passing_yards] = cells[9].text
  new_game[:passing_touchdowns] = cells[11].text
  new_game[:interceptions] = cells[12].text

  new_game[:rushing_attempts] = cells[16].text
  new_game[:rushing_yards] = cells[17].text
  new_game[:rushing_touchdowns] = cells[19].text

  new_game[:receiving_yards] = 0
  new_game[:receptions] = 0
  new_game[:receiving_touchdowns] = 0

  new_game[:fumbles_lost] = cells[21].text

  return type_game(new_game)
end

def get_rb_game(cells, id, year)
  new_game = { id: id, year: year }
  new_game[:week] = cells[0].text
  new_game[:position] = "RB"

  new_game[:passing_completions] = 0
  new_game[:passing_attempts] = 0
  new_game[:passing_yards] = 0
  new_game[:passing_touchdowns] = 0
  new_game[:interceptions] = 0

  new_game[:rushing_attempts] = cells[6].text
  new_game[:rushing_yards] = cells[7].text
  new_game[:rushing_touchdowns] = cells[10].text

  new_game[:receiving_yards] = cells[12].text
  new_game[:receptions] = cells[15].text
  new_game[:receiving_touchdowns] = cells[9].text

  new_game[:fumbles_lost] = cells[17].text

  return type_game(new_game)
end

def get_wr_game(cells, id, year)
  new_game = { id: id, year: year }
  new_game[:week] = cells[0].text
  new_game[:position] = "WR"

  new_game[:passing_completions] = 0
  new_game[:passing_attempts] = 0
  new_game[:passing_yards] = 0
  new_game[:passing_touchdowns] = 0
  new_game[:interceptions] = 0

  new_game[:rushing_attempts] = cells[11].text
  new_game[:rushing_yards] = cells[12].text
  new_game[:rushing_touchdowns] = cells[15].text

  new_game[:receiving_yards] = cells[7].text
  new_game[:receptions] = cells[6].text
  new_game[:receiving_touchdowns] = cells[10].text

  new_game[:fumbles_lost] = cells[17].text

  return type_game(new_game)
end

def get_te_game(cells, id, year)
  new_game = { id: id, year: year }
  new_game[:week] = cells[0].text
  new_game[:position] = "TE"

  new_game[:passing_completions] = 0
  new_game[:passing_attempts] = 0
  new_game[:passing_yards] = 0
  new_game[:passing_touchdowns] = 0
  new_game[:interceptions] = 0

  new_game[:rushing_attempts] = cells[11].text
  new_game[:rushing_yards] = cells[12].text
  new_game[:rushing_touchdowns] = cells[15].text

  new_game[:receiving_yards] = cells[7].text
  new_game[:receptions] = cells[6].text
  new_game[:receiving_touchdowns] = cells[10].text

  new_game[:fumbles_lost] = cells[17].text

  return type_game(new_game)
end

def get_wr_te_game(cells, id, year)
  new_game = { id: id, year: year }
  new_game[:week] = cells[0].text
  new_game[:position] = "WR/TE"

  new_game[:passing_completions] = 0
  new_game[:passing_attempts] = 0
  new_game[:passing_yards] = 0
  new_game[:passing_touchdowns] = 0
  new_game[:interceptions] = 0

  new_game[:rushing_attempts] = cells[11].text
  new_game[:rushing_yards] = cells[12].text
  new_game[:rushing_touchdowns] = cells[15].text

  new_game[:receiving_yards] = cells[7].text
  new_game[:receptions] = cells[6].text
  new_game[:receiving_touchdowns] = cells[10].text

  new_game[:fumbles_lost] = cells[17].text

  return type_game(new_game)
end

def is_a_legit_row?(cells)
  return (cells.length > 17 && cells[0].text != "WK" && cells[4].text == "1" && cells[1].text != "TOTAL")
end

def get_players_position(doc)
  player_number = doc.css(".player-number").text
  if player_number != ""
    return doc.css(".player-number").text.split(" ")[1]
  else
    player_quick_stats = doc.css(".player-quick-stats").css(".player-quick-stat-item-header")
    if player_quick_stats.length > 0
      header = player_quick_stats[0].text
      if header == "CAR"
        return "RB"
      elsif header == "REC"
        return "WR/TE"
      elsif header == "TDS"
        return "QB"
      end
    end
  end
end

def finish_season_stats()
  total_count = SeasonStat.all.count()
  current = 1
  SeasonStat.all.each do |stat|
    current += 1
    stat.fantasy_points_reg = stat.calculate_season_fantasy_points
    stat.fantasy_points_ppr = stat.calculate_season_fantasy_points_ppr
    stat.rank_reg = SeasonStat.where("fantasy_points_reg >= ? AND year = ? AND position = ?", stat.fantasy_points_reg, stat.year, stat.position).count + 1
    stat.rank_ppr = SeasonStat.where("fantasy_points_ppr >= ? AND year = ? AND position = ?", stat.fantasy_points_ppr, stat.year, stat.position).count + 1
    stat.experience_at_season = SeasonStat.where("player_id = ? AND year <= ?", stat.player.id, stat.year).count
    puts "#{current}/#{total_count}"
    stat.save!
  end
end
