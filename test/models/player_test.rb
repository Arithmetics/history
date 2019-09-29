require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @player_one = players(:player_one)
  end

  test "valid player" do
    assert @player_one.valid?
  end

  test "invalid without name" do
    invalid_player = Player.new()
    refute invalid_player.valid?, "player not valid without a name"
  end
end
