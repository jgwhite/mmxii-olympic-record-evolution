require 'bundler/setup'
require 'nokogiri'
require 'open-uri'
require 'json'

BASE = 'http://www.databaseolympics.com'

index = Nokogiri::HTML open BASE

data_sets = []

index.css('.pt10')[1].css('a').each do |link|
  url = link['href']
  page = Nokogiri::HTML open BASE + url
  page.css('.cl2').each do |row|
    cells = row.css 'td'
    data = {
      year: page.at_css('.nme b').content[/\d+/].to_i,
      country: cells[0].at_css('a').content,
      gold: cells[1].content,
      silver: cells[2].content,
      bronze: cells[3].content,
      total: cells[4].content
    }
    puts data
    data_sets << data
  end
end

File.open('olympic-results.json', 'w') { |f| f << data_sets.to_json }
