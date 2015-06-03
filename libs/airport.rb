class Airport
	attr_accessor :name, :code
	def initialize(airport_code)
		begin
		airports = JSON.parse(HTTParty.get("http://assets.cathaypacific.com/json/destinations/airports.json").body)['airports']
		   @name = airports.select{|airport| airport['airportCode'] == airport_code}[0]['airportDetails']['city']['name']
		   @code = airport_code
		rescue
			puts "ERROR: Airport not found."
		end
	end
end