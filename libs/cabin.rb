class Cabin
	attr_accessor :name, :code
	def initialize(cabin_code)
		cabin_code.upcase!
		case cabin_code
		when "Y"
		  	@name = "Economy Class"
		when "W"
		  	@name = "Premium Economy Class"
		when "C"
		  	@name = "Business Class"
		when "F"
		  	@name = "First Class"
		end
		@code = cabin_code
	end
end