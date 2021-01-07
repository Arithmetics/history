json.waiver_bids @bids do |bid|
  json.extract! bid, :id, :amount, :year, :week, :winning
end