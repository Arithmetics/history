require "nokogiri"
require "selenium-webdriver"
require "open-uri"
require "csv"
require "uri"

def driver_start(current_league_url)
  driver = Selenium::WebDriver.for :firefox
  driver.navigate.to "https://www.nfl.com/login?s=fantasy&returnTo=http%3A%2F%2Ffantasy.nfl.com%2Fleague%2F400302"
  sleep(4)
  username = driver.find_element(id: "gigya-loginID-60062076330815260")
  password = driver.find_element(id: "gigya-password-85118380969228590")
  submit = driver.find_element(xpath: "/html/body/div[5]/main/div/div[2]/div[2]/div/form/div[1]/div[4]/input")
  sleep(1)
  username.send_keys("brock.m.tillotson@gmail.com")
  password.send_keys(ENV["NFL_PASSWORD"])
  submit.click()
  sleep(2)
  driver.navigate.to current_league_url
  puts "handing off driver"
  return driver
end

def verify_current_week(driver, current_league_url, week)
  if week < 1 || week > 13
    throw("supplied week, #{week}, is not a regular season week")
  end
  driver.navigate.to "#{current_league_url}?standingsTab=standings&standingsType=overall"
  sleep(2)
  doc = Nokogiri::HTML(driver.page_source)
  ts = doc.css(".teamRecord")
  team_record = doc.css(".teamRecord")[6].text()
  games = team_record.split("-")
  weeks_played = 0
  games.each do |game|
    weeks_played += game.to_i
  end

  if weeks_played != (week - 1)
    throw("Something may be wrong with your set week, please check or override verify_current_week \n weeks played: #{weeks_played}, set week #{week}")
  end
  puts "verify_current_week passed"
end
