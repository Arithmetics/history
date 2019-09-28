require "selenium-webdriver"
require "nokogiri"
require "csv"
require "pp"

def get_owners_teams(year, driver, owners)
  driver.navigate.to "https://fantasy.nfl.com/league/400302/history/#{year}/owners"
  sleep(3)
  doc = Nokogiri::HTML(driver.page_source)
  owners_table = doc.css(".tableType-team")
  owner_rows = owners_table.css("tbody").css("tr")

  owner_rows.each do |row|
    owner = row.css(".teamOwnerName").text
    if owners[owner] == nil
      owners[owner] = []
    end
    team_name = row.css(".teamName").text
    owners[owner].push([year, team_name])
  end
end

years = [2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018]

driver = Selenium::WebDriver.for :firefox

########### driver setup and login #############
driver.navigate.to "https://www.nfl.com/login?s=fantasy&returnTo=http%3A%2F%2Ffantasy.nfl.com%2Fleague%2F400302"
sleep(1)
username = driver.find_element(id: "fanProfileEmailUsername")
password = driver.find_element(id: "fanProfilePassword")
submit = driver.find_element(xpath: "/html/body/div[1]/div/div/div[2]/div[1]/div/div/div[2]/main/div/div[2]/div[2]/form/div[3]/button")
sleep(1)
username.send_keys("brock.m.tillotson@gmail.com")
password.send_keys("password") #REPLACE)_TAG
submit.click()
sleep(2)

temp_owners = {}
years.each do |year|
  get_owners_teams(year, driver, temp_owners)
end
puts temp_owners

CSV.open("../../db/seeds/teams.csv", "wb") do |csv|
  temp_owners.each do |owner, teams|
    teams.each do |entry|
      csv << [owner, entry[0], entry[1]]
    end
  end
end

driver.quit
