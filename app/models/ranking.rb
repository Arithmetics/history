class Ranking < ApplicationRecord
  belongs_to :player

  validates :ranking, presence: true
  validates :year, presence: true
  validates :player, uniqueness: { scope: :year,
                                    message: "only one ranking per player per year" }
  validates :position, presence: true, inclusion: { in: %w{QB RB WR TE} }
end
