require "test_helper"

class OwnerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @valid_owner = owners(:valid)
  end

  test "valid owner" do
    assert @valid_owner.valid?
  end

  test "invalid without name" do
    invalid_owner = Owner.new()
    refute invalid_owner.valid?, "owner not valid without a name"
  end

  test "no duplicate owner names" do
    duplicate_owner = Owner.new(name: "Dude")
    duplicate_owner.valid?
    assert_includes(duplicate_owner.errors[:name], "has already been taken")
  end

  test "has correct number of fantasy teams" do
    assert_equal 2, @valid_owner.fantasy_teams.size
  end
end
