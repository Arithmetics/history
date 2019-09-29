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
