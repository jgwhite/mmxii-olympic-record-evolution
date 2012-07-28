require 'bundler/setup'
require 'mongoid'
require 'csv'

Mongoid.load! 'mongoid.yml', :development

class DataSet
  include Mongoid::Document

  field :year, :type => Integer
  field :country_code
  field :gdp_per_capita, :type => Float
  field :gold_medals, :type => Integer
  field :silver_medals, :type => Integer
  field :bronze_medals, :type => Integer

end

olympic_results = JSON.parse File.read 'olympic-results.json'
olympic_results.each do |entry|
  year = entry['year']
  entry['countries'].each do |country|
    data_set = DataSet.find_or_create_by(
      year: year,
      country_code: country['country_code']
    )
    data_set.update_attributes(
      gold_medals: country['gold'],
      silver_medals: country['silver'],
      bronze_medals: country['bronze']
    )
  end
end

CSV.open('gdp-per-capita.csv', 'r') do |csv|
  csv.each do |row|
    country_code = row[2]
    DataSet.where(country_code: country_code).each do |data_set|
      year = data_set.year
      offset = (year - 1960) + 3
      next if offset < 0
      data_set.update_attributes gdp_per_capita: row[offset]
    end
  end
end

