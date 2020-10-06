json.players @players do |player|
  json.extract! player, :id, :name, :picture_id, :nfl_URL_name, :birthdate
  json.set! "player_name", player.name
  json.set! "career_stats", player.career_stats.deep_transform_keys! { |key| key.camelize(:lower) }
end
