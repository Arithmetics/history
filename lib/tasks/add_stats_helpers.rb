

def player_stat_update()
  begin
    ActiveRecord::Base.transaction do
      Player.update_all_season_stats()
    end
  end
  begin
    ActiveRecord::Base.transaction do
      SeasonStat.finish_season_stats()
    end
  end
end
