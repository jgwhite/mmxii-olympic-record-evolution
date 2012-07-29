require 'bundler/setup'
require 'nokogiri'
require 'open-uri'
require 'json'

country_codes_page = Nokogiri::HTML open 'http://wits.worldbank.org/WITS/wits/WITSHELP/Content/Codes/Country_Codes.htm'
country_codes = {}
country_codes_page.css('.WT1 tr').each do |row|
  paras = row.css 'p'
  name = paras[0].content.strip
  next if name == 'Country Name'
  code = paras[1].content.strip
  country_codes[name] = code
end

puts country_codes

BASE = 'http://www.databaseolympics.com'

index = Nokogiri::HTML open BASE

data_sets = []

index.css('.pt10')[1].css('a').each do |link|
  url = link['href']
  page = Nokogiri::HTML open BASE + url
  page.css('.cl2').each do |row|
    cells = row.css 'td'
    country_name = cells[0].at_css('a').content
    country_code = country_codes[country_name] || cells[0].at_css('a')['href'].match(/cty=([A-Z]+)/)[1]
    data = {
      year: page.at_css('.nme b').content[/\d+/].to_i,
      country_code: country_code,
      country_name: country_name,
      gold: cells[1].content,
      silver: cells[2].content,
      bronze: cells[3].content,
      total: cells[4].content
    }
    puts data
    data_sets << data
  end
end

File.open('sources/olympic-results.json', 'w') { |f| f << data_sets.to_json }
