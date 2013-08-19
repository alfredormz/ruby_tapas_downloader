require 'nokogiri'
require 'open-uri'
require 'optparse'

FEED_URL = "https://rubytapas.dpdcart.com/feed"

options = {}

optparse = OptionParser.new do |option_parser|
  option_parser.banner = "Usage: ruby_tapas_downloader.rb [options]"

  option_parser.on("-u", "--username USERNAME", "Username/email") do |e|
    options[:username] = e
  end
  option_parser.on("-p", "--password PASSWORD", "Password") do |p|
    options[:password] = p
  end
end

optparse.parse!

unless options[:username] && options[:password]
  puts optparse
  exit(1)
end

http_options = {
  http_basic_authentication: [options[:username], options[:password]]
}

feed_content = open(FEED_URL, http_options).read
doc = Nokogiri::XML(feed_content)

doc.xpath("//enclosure").each do |enclosure|

  url       = enclosure['url']
  file_name = url.split("/").last

  unless File.exist? file_name
    puts "Downloading #{file_name}..."
    File.open(file_name, 'wb') do |file|
      file.write open(url, http_options).read
    end
  else
    puts "File #{file_name} already exist."
  end
end
