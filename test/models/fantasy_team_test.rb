require "test_helper"

class FantasyTeamTest < ActiveSupport::TestCase
  def setup
    @valid_team = fantasy_teams(:squad_one)
  end

  test "valid fantasy team" do
    assert @valid_team.valid?
  end

  test "invalid without name" do
    invalid_team = FantasyTeam.new(year: 2019)
    refute invalid_team.valid?, "fantasy team not valid without a name"
  end

  test "invalid without year" do
    invalid_team = FantasyTeam.new(name: "asdf")
    refute invalid_team.valid?, "fantasy team not valid without a year"
  end
end
