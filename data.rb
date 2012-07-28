require 'bundler/setup'
require 'mongoid'
require 'csv'

Mongoid.load! 'mongoid.yml', :development

class DataSet
  include Mongoid::Document

  field :year, :type => Integer
  field :country
  field :gdp_per_capita, :type => Float
  field :gold_medals, :type => Integer, :default => 0
  field :silver_medals, :type => Integer, :default => 0
  field :bronze_medals, :type => Integer, :default => 0
  field :total_medals, :type => Integer, :default => 0

end

class HackData
  def self.run
    DataSet.delete_all

    olympic_results = JSON.parse File.read 'sources/olympic-results.json'
    olympic_results.each do |entry|
      next if entry['year'] < 1960

      puts "Adding #{entry['country']} #{entry['year']}"

      data_set = DataSet.find_or_initialize_by(
        year: entry['year'],
        country: entry['country']
      )
      data_set.update_attributes(
        gold_medals: entry['gold'],
        silver_medals: entry['silver'],
        bronze_medals: entry['bronze'],
        total_medals: entry['total']
      )
    end

    CSV.open('sources/gdp-per-capita.csv', 'r') do |csv|
      csv.each do |row|
        country = row[2]
        next if country == 'Country Code'

        year  = 1960

        while year <= 2008
          puts "Adding #{country} #{year}"
          offset = (year - 1960) + 3
          if offset >= 0
            entry = DataSet.find_or_initialize_by country: country, year: year
            entry.update_attributes :gdp_per_capita => row[offset]
          end
          year += 4
        end
      end
    end

    File.open('data.json', 'w') { |f| f << DataSet.all.to_json }
  end
end

