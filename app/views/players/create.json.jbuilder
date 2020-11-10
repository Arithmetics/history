json.player do
  json.extract! @player, :id, :name, :birthdate, :picture_id, :nfl_URL_name, :created_at
end
