class SeasonCard < ApplicationRecord
  belongs_to :season_stat
  belongs_to :owner
  
  has_many :season_card_ownerships
  has_many :users, :through => :season_card_ownerships

  def self.create_seasons_cards(year)
    season_stats = SeasonStat.where(year: year).all
    season_stats.each do |stat|
      # player for other checks
      player = stat.player

      # auction price
      purchase = player.purchases.where(year: year).first
      auction_price = 0
      if purchase != nil
        auction_price = purchase.price
      end

      # breakout
      breakout = false
      preseason_ranking = Ranking.where(year: year, player: player ).first
      if stat.is_top_performer && (!preseason_ranking || !preseason_ranking.was_projected_top_performer) 
        breakout = true
      end

      # repeat
      repeat = false
      previous_season = SeasonStat.where(year: year - 1, player: player).first
      if previous_season && stat.is_top_performer() && previous_season.is_top_performer()
        repeat = true
      end
          
      #champion
      champion = player.won_championship(year)

      #owner 
      owner = player.main_owner_in_year(year)

      if owner != nil
        new_card = SeasonCard.create!(
          season_stat: stat,
          auction_price: auction_price, 
          breakout: breakout, 
          repeat: repeat, 
          champion: champion, 
          owner: owner
        )
      end
    end
  end
  #
end
