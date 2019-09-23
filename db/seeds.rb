# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# owners
owners = [
  "Matt Makarowsky",
  "Jeremy Abbot",
  "Kevin Kern",
  "Brock Tillotson",
  "Daniel McGunnigle",
  "Joe Whitaker",
  "Jordan Highland",
  "Keenan Lopez",
  "Brandon Troxel",
  "Dennis Ranck",
  "Woody Toms",
  "Mike Rich",
  "Matt Flack",
  "Tim Sampson",
  "Jared Maybee",
  "Eric Kjemperud",
]

owners.each do |owner|
  x = Owner.create(name: owner)
end
