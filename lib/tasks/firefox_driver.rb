require "nokogiri"
require "selenium-webdriver"
require "open-uri"
require "csv"
require "uri"

def driver_start(current_league_url)
  puts "creating driver"
  driver = Selenium::WebDriver.for :firefox
  driver.manage.timeouts.implicit_wait = 20
  driver.navigate.to "https://www.nfl.com/account/sign-in"
  username = driver.find_element(xpath: "/html/body/div[5]/main/div/div[2]/div[2]/div/form/div[1]/div[1]/input")
  password = driver.find_element(xpath: "/html/body/div[5]/main/div/div[2]/div[2]/div/form/div[1]/div[2]/input")
  submit = driver.find_element(xpath: "/html/body/div[5]/main/div/div[2]/div[2]/div/form/div[1]/div[4]/input")
  sleep(3)
  username.send_keys("brock.m.tillotson@gmail.com")
  password.send_keys(ENV["NFL_PASSWORD"])
  sleep(3)
  submit.click()
  # driver.find_element(xpath: "/html/body/div[4]/header/div/nav[2]/ul/li[4]/a/span/svg/use//svg/path")
  sleep(10)
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
