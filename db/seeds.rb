# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# owners and fantasy_teams
owners = {
  "Matt Makarowsky" => [["Greatest Show on Turf", 2011]],
  "Jeremy Abbot" => [[]],
  "Kevin Kern" => [["The Real McCoy", 2011]],
  "Brock Tillotson" => [["Making Sure You Ain't Last"]],
  "Daniel McGunnigle" => [["The Arian Brotherhood", 2011]],
  "Joe Whitaker" => [["Maclin on Your Girl", 2011]],
  "Jordan Highland" => [["lights CAMera action", 2011]],
  "Keenan Lopez" => [["CjCj 30mil", 2011]],
  "Brandon Troxel" => [["Hood niggas", 2011]],
  "Dennis Ranck" => [[]],
  "Woody Toms" => [[]],
  "Mike Rich" => [[]],
  "Matt Flack" => [["Occupy The Endzone", 2011]],
  "Tim Sampson" => [["Living In a Van By The Rivers", 2011]],
  "Jared Maybee" => [["Best in Schaub", 2011]],
  "Eric Kjemperud" => [["Bro Flacco", 2011]],
}

owners.each do |owner, teams|
  x = Owner.create(name: owner)
  if (teams.length > 0)
    teams.each do |team|
      x.fantasy_teams.create(name: team[0], year: team[1])
    end
  end
end
