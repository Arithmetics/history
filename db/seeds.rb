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
