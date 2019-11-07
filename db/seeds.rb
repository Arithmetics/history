require "csv"

# owners and fantasy_teams
team_rows = CSV.read("#{Rails.root}/db/seed_files/teams.csv")

team_rows.each do |row|
  if row.length > 2
    x = Owner.find_by_name(row[0])
    if x == nil
      x = Owner.create(name: row[0])
      puts x
    end
    x.fantasy_teams.create(name: row[2], year: row[1])
    puts x.fantasy_teams
  end
end

# players (2011 -- 2018)
CSV.foreach("#{Rails.root}/db/seed_files/2011_2018_players.csv", :headers => true) do |row|
  birthdate = Date::strptime(row["birthdate"], "%m/%d/%Y")
  x = Player.create(id: row["profile_id"], name: row["name"], birthdate: birthdate)
  puts "#{x.name} - #{x.id} - #{x.birthdate}"
end

# team defense (players)
CSV.foreach("#{Rails.root}/db/seed_files/nfl_teams.csv", :headers => true) do |row|
  x = Player.create(id: row["profile_id"], name: row["name"])
  puts "#{x.name} - #{x.id}"
end

# fantasy starts 2011-2018
CSV.foreach("#{Rails.root}/db/seed_files/2011_2018_fantasy_starts.csv", :headers => true) do |row|
  owner = Owner.find_by_name(row["owner"])
  if owner == nil
    puts "couldnt find an owner"
    puts row["owner"]
    exit(false)
  end
  fantasy_team = owner.fantasy_teams.find_by_year(row["year"])

  player = Player.find(row["profile_id"])
  if fantasy_team == nil || player == nil
    if fantasy_team == nil
      puts "could not find fantasy_team for #{row["id"]} #{row["name"]}"
    elsif player == nil
      puts "could not find player for #{row["id"]} #{row["name"]}"
    end
  else
    x = FantasyStart.create(
      points: row["points"],
      player: player,
      fantasy_team: fantasy_team,
      year: row["year"],
      week: row["week"],
      position: row["position"],
    )
    if !x.valid?
      puts "could not create fantasy_start \n #{x} \n #{x.errors}"
    else
      puts x
    end
  end
end

# fantasy_games 2011-2018
CSV.foreach("#{Rails.root}/db/seed_files/2011_2018_fantasy_games.csv", :headers => true) do |row|
  away_team = FantasyTeam.find_by(name: row["away_team"], year: row["year"])

  if away_team == nil
    puts "couldnt find a away team"
    puts row["away_team"]
    exit(false)
  end

  puts away_team.name

  home_team = FantasyTeam.find_by(name: row["home_team"], year: row["year"])

  if home_team == nil
    puts "couldnt find a home team"
    puts row["home_team"]
    exit(false)
  end

  puts home_team.name

  x = FantasyGame.create(
    away_fantasy_team: away_team,
    away_score: row["away_points"].to_f,
    home_score: row["home_points"].to_f,
    home_fantasy_team: home_team,
    year: row["year"],
    week: row["week"],
  )
  if !x.valid?
    puts "could not create fantasy_start \n #{x} \n #{x.errors}"
    exit(false)
  else
    puts x
  end
end

# 2013 - 2018 purchases
CSV.foreach("#{Rails.root}/db/seed_files/2013_2018_purchases.csv", :headers => true) do |row|
  owner = Owner.find_by(name: row["owner"])
  team = FantasyTeam.find_by(owner_id: owner, year: row["year"])

  if team == nil
    puts "couldnt find a team"
    puts row["owner"]
    puts row["year"]
    exit(false)
  end

  player = Player.find(row["player_id"])
  if player == nil
    puts "couldnt find a team"
    puts row["player_id"]
    exit(false)
  end

  x = Purchase.create(
    year: row["year"],
    position: row["position"],
    price: row["price"],
    fantasy_team: team,
    player: player,
  )
  if !x.valid?
    puts "could not create purchase \n #{x} \n #{x.errors}"
    exit(false)
  else
    puts x
  end
end

# old - 2018 cuumulative season stats
CSV.foreach("#{Rails.root}/db/seed_files/cuumulative_seasons.csv", :headers => true) do |row|
  player = Player.find(row["profile_id"])

  if player == nil
    puts "couldnt find a player"
    puts row["profile_id"]
    exit(false)
  end

  season_count = player.season_stats.count

  year = row["year"]
  season_start = Date.parse("#{year}-09-01")
  birthdate = player.birthdate

  age_at_season = ((season_start - birthdate) / 365).to_f.round(2)

  x = SeasonStat.create(
    year: row["year"],
    games_played: row["games_played"],
    passing_completions: row["passing_completions"],
    passing_attempts: row["passing_attempts"],
    passing_yards: row["passing_yards"],
    passing_touchdowns: row["passing_touchdowns"],
    interceptions: row["interceptions"],
    rushing_attempts: row["rushing_attempts"],
    rushing_yards: row["rushing_yards"],
    rushing_touchdowns: row["rushing_touchdowns"],
    receiving_yards: row["receiving_yards"],
    receptions: row["receptions"],
    receiving_touchdowns: row["receiving_touchdowns"],
    fumbles_lost: row["fumbles_lost"],
    age_at_season: age_at_season,
    experience_at_season: season_count,
    player: player,
  )

  if !x.valid?
    puts "could not create season stat \n #{x} \n #{x.errors}"
    exit(false)
  else
    puts x
  end
end
