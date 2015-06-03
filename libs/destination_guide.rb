class DestinationGuide
		attr_accessor :url, :attractions
	def initialize(destination_name, language="en", country="HK")
		@url = "http://www.cathaypacific.com/cx/#{language}_#{country}/destinations/things-to-do-in-#{destination_name.downcase.gsub(' ','-')}.html"
		@attractions = []
		html = Nokogiri::HTML(open(@url))
		html.css("div.to-do-list-fallback div.item").each do |item|
			@attractions << Attraction.new(item)
		end
	end
end

class Attraction < DestinationGuide
	attr_accessor :image_url, :title, :intro, :category
	def initialize(item)
		@image_url = 'http://www.cathaypacific.com' + item.at_css("img")['src']
		@title = item.at_css("div.title").text
		@intro = item.at_css("div.intro").text.strip
		@category = item.at_css("div.category").text
	end
end