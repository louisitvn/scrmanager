raise "No $DATABASE_URL found" unless ENV['DATABASE_URL']

require 'optparse'

$options = {}
parser = OptionParser.new("", 24) do |opts|
  opts.banner = "\nVersion: 1.0 (Dec-2013)\n\n"

  opts.on("-o", "--output OUTPUT", "Output SQLite3 file for storing scraped data") do |v|
    $options[:output] = v
  end

  opts.on_tail('-h', '--help', 'Displays this help') do
		puts opts, "", help
    exit
	end
end

def help
  return <<-eos
The scraper script includes two parts

  1. scraper.rb: scrape data from the internet and store to a local SQLite3 database
  2. to_csv.rb: read the local SQLite3 database and generate TSV output

Procedures:

  1. Run the scraper script and store scraped data to  SQLite3 DB file main.db
	   
        ruby scraper.rb --output=main.db

  2. After the scraper process is done, run the parser to read the main.db database
     and generate the CSV file data.csv

        ruby to_csv.rb --input=main.db --output=data.csv

Notes:
- The scraper script scraper.rb supports resuming. Just run the script again in case
  of any failure to have it start from where it left off (due to internet
  connection problem for instance). Be sure to specify the same SQLite output file.
- As scraper.rb stores items ony-by-one, you can run the to_csv.rb script
  even when the scraping process is not complete yet.
  Then it will export the available items in the local database

eos
end

begin
  parser.parse!
rescue SystemExit => ex
  exit
rescue Exception => ex
  puts "\nERROR: #{ex.message}\n\nRun ruby crawler.rb -h for help\n\n"
  exit
end

if $options[:output].nil?
  puts "\nPlease specify the output file: -o\n\n"
  exit
end

#############################################

require 'rubygems'
require 'active_record'
require 'sqlite3'
require 'mechanize'

$outdb = $options[:output]

ActiveRecord::Base.establish_connection(
  #adapter: 'sqlite3',
  #database: $outdb,
  #timeout: 15000 # You'll only get the BusyException if it takes longer than 15 seconds.
  ENV['DATABASE_URL']
)

# the Item model for handling items table
class Item < ActiveRecord::Base
  serialize :locations, JSON
end

# the databse schema
class MySchema < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :company_number
      t.string :company_name
      t.string :company_type
      t.string :member_full_name
      t.string :member_first_name
      t.string :member_last_name
      t.string :member_title
      t.string :member_is_admin
      t.string :member_phone
      t.string :member_number
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.string :phone
      t.string :email
      t.string :website
      t.string :regions
      t.string :industries
      t.string :about
      
      t.text   :locations
      t.integer :page
      t.string :url
      t.text   :html

      t.timestamps
    end
  end
end

# initiate the database if not existed
begin
  MySchema.new.migrate(:up)
rescue Exception => ex
  
end

class Scraper
  URL = 'https://network.axial.net/app/transaction_profile/public_search/?tpsearch_ebitda=&xtype=ALL&tpsearch_keywords=.&search_submitted=1&use_qclass=1&tpsearch_top_level_industry=0&tpsearch_revenue=&page='
  BASE = 'https://network.axial.net'
  def initialize
    @a = Mechanize.new
  end

  def run
    last = Item.last
    if last
      last_page = last.page
    else
      last_page = 0
    end
    last_page.upto(1056) do |page|
      upage_url = URL + page.to_s
      parser = @a.get(upage_url).parser

      puts upage_url
      
      urls =  parser.css('ul.tp-results-list > li.axl-result-item h3 a.axl-link').map{|a| 
                if a.parent.next_element.css('a.axl-link').empty?
                  a.attributes['href'].value
                else
                  a.parent.next_element.css('a.axl-link').first.attributes['href'].value
                end
              }
      
      urls.map!{|url| File.join(BASE, url)}

      urls.each do |url|
        puts url
        get(url, {page: page})
        puts "---------------------------------"
      end
    end
  end

  def get(url, extra)
    if Item.exists?(url: url)
      puts "Already scraped"
      return
    end

    #begin
      resp = @a.get(url, extra)
    #rescue Exception => ex
    #  item = Item.new
    #  item.url = url
    #  item.page = extra[:page]
    #  item.save
    #  puts "Something wrong"
    #  return
    #end

    if resp.body[/The company you tried to reach doesn.t exist/]
      item = Item.new
      item.url = url
      item.company_name = "**** company not exists ****"
      item.page = extra[:page]
      item.save
      puts "**** company not exists ****"
      return
    end

    json = JSON.parse resp.body[/(?<=companyProfileCtrl.load_company_profile\().*}(?=[^}]+Admin)/]
    
    ajax_url = "https://network.axial.net/am/companies/profile-data/?company_id=#{json['public_id']}&view_state=Admin&profile_photo_size=64"
    
    ajax_resp = @a.get(ajax_url)
    ajax_json = JSON.parse(ajax_resp.body)

    ajax_json['response']['members']['members'].each do |member|
      item = Item.new

      item.url = url
      item.page = extra[:page]
      item.html = resp.body

      item.member_full_name = member['name']
      item.member_first_name = member['name'].split("\s").first
      item.member_last_name = member['name'].split("\s").last
      item.member_title = member['title']
      item.member_is_admin = member['is_admin']
      item.member_number = member['member_id']
      item.member_phone = member['has_phone']
      
      item.company_number = json['public_id']
      item.company_name = json['name']
      item.company_type = json['type_name']
      item.locations = json['locations']
      item.address = json['locations'].first['address']['street_address'].join(' ')
      item.city = json['locations'].first['address']['locality']
      item.state = json['locations'].first['address']['region']
      item.country = json['locations'].first['address']['country']
      item.phone = json['locations'].first['phone']
      # item.email = 
      item.website = json['website']
      item.regions = json['geographyNames'].join(', ')
      item.industries = json['industries'].map{|e| e['name']}.join(', ')
      item.about = json['description']

      item.save
      puts "#{item.company_name}, #{Item.count}, page #{item.page}"
    end
  end
end

e = Scraper.new
e.run
