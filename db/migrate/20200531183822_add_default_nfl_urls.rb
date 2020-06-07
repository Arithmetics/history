class AddDefaultNflUrls < ActiveRecord::Migration[6.0]
  def up
    Player.all.each do |player|
      player.nfl_URL_name = player.name.gsub(" ", "-").gsub(".", "-").gsub("--", "-").downcase.squish
      player.save!
    end

    special_edits = [{ id: 2507175, url: "steve-smith-2" },
                     { id: 2508048, url: "mike-williams-4" },
                     { id: 2506140, url: "ryan-grant-2" },
                     { id: 2504531, url: "mike-vick" },
                     { id: 2504651, url: "chad-johnson" },
                     { id: 2540175, url: "le-veon-bell" },
                     { id: 2507374, url: "stephen-hauschka" },
                     { id: 2495227, url: "da-rel-scott" },
                     { id: 2556521, url: "ka-imi-fairbairn" },
                     { id: 2560878, url: "tre-quan-smith" },
                     { id: 2557994, url: "d-onta-foreman" },
                     { id: 2562659, url: "n-keal-harry" },
                     { id: 2541147, url: "charles-d-johnson" },
                     { id: 2560770, url: "ronald-jones" },
                     { id: 2506878, url: "matt-leinart-2" },
                     { id: 2501016, url: "jason-hanson-2" },
                     { id: 2508112, url: "rob-housler" },
                     { id: 2562685, url: "d-k-metcalf" },
                     { id: 100001, url: "" }, #defense
                     { id: 100002, url: "" }, #defense
                     { id: 100003, url: "" }, #defense
                     { id: 100004, url: "" }, #defense
                     { id: 100005, url: "" }, #defense
                     { id: 100006, url: "" }, #defense
                     { id: 100007, url: "" }, #defense
                     { id: 100008, url: "" }, #defense
                     { id: 100009, url: "" }, #defense
                     { id: 100010, url: "" }, #defense
                     { id: 100011, url: "" }, #defense
                     { id: 100012, url: "" }, #defense
                     { id: 100013, url: "" }, #defense
                     { id: 100014, url: "" }, #defense
                     { id: 100015, url: "" }, #defense
                     { id: 100016, url: "" }, #defense
                     { id: 100017, url: "" }, #defense
                     { id: 100018, url: "" }, #defense
                     { id: 100019, url: "" }, #defense
                     { id: 100020, url: "" }, #defense
                     { id: 100021, url: "" }, #defense
                     { id: 100022, url: "" }, #defense
                     { id: 100023, url: "" }, #defense
                     { id: 100024, url: "" }, #defense
                     { id: 100025, url: "" }, #defense
                     { id: 100026, url: "" }, #defense
                     { id: 100027, url: "" }, #defense
                     { id: 100028, url: "" }, #defense
                     { id: 100029, url: "" }, #defense
                     { id: 100030, url: "" }, #defense
                     { id: 100031, url: "" }, #defense
                     { id: 100032, url: "" } #defense
]

    special_edits.each do |id, url|
      x = Player.find(id)
      x.nfl_URL_name = url
      s.save!
    end
  end

  def down
    Player.all.each do |player|
      player.nfl_URL_name = ""
      player.save!
    end
  end
end
