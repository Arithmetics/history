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
