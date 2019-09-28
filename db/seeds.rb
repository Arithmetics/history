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
