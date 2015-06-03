require 'rubygems'
require 'httparty'
require 'json'

module Silverpop
    class Client
    	include HTTParty
	    attr_accessor :host, :username, :password, :debug, :session, :session_id, :session_encoding, :endpoint
		def initialize(config={}, debug=false)
			puts username = config[:username] 
			puts password = config[:password]
			endpoint = config[:endpoint] #'http://api3.silverpop.com/XMLAPI'

			unless username
				username = ENV['SILVERPOP_USERNAME']
			end
			raise Error, 'You must provide username for Silverpop API access.' unless username
			@username = username

			unless password
				password = ENV['SILVERPOP_PASSWORD']
			end
			raise Error, 'You must provide password for Silverpop API access.' unless password
			@password = password

			unless endpoint
				endpoint = ENV['SILVERPOP_HOST']
			end

			puts response = self.class.post(endpoint, :body => {:xml => "<Envelope><Body><Login><USERNAME>#{username}</USERNAME><PASSWORD>#{password}</PASSWORD></Login></Body></Envelope>"})
			@session_id = response.parsed_response["Envelope"]["Body"]["RESULT"]["SESSIONID"]
			@session_encoding = response.parsed_response["Envelope"]["Body"]["RESULT"]["SESSION_ENCODING"]
			@endpoint = endpoint + @session_encoding
			@debug = debug
		end

		def add_recipient(list_id, columns = {})
			column_nodes = []
			columns.each do |key, value|
				column_nodes << "<COLUMN><NAME>#{key}</NAME><VALUE>#{value}</VALUE></COLUMN>"
			end

			xml = "<Envelope><Body><AddRecipient><LIST_ID>#{list_id}</LIST_ID><CREATED_FROM>1</CREATED_FROM><CONTACT_LISTS></CONTACT_LISTS>" + column_nodes.join + "</AddRecipient></Body></Envelope>"
			api(xml)
		end	

		def update_recipient(list_id, columns={})
			column_nodes = []
			columns.each do |key, value|
				column_nodes << "<COLUMN><NAME>#{key}</NAME><VALUE>#{value}</VALUE></COLUMN>"
			end

			xml = "<Envelope><Body><UpdateRecipient><LIST_ID>#{list_id}</LIST_ID>" + column_nodes.join + "</UpdateRecipient></Body></Envelope>"
			api(xml)
		end

		def insert_update_relational_table(table_id, columns={})
			column_nodes = []
			columns.each do |key, value|
				column_nodes << "<COLUMN name='#{key}'><![CDATA[#{value}]]></COLUMN>"
			end

			xml = "<Envelope><Body><InsertUpdateRelationalTable><TABLE_ID>#{table_id}</TABLE_ID><ROWS><ROW>"+ column_nodes.join + "</ROW></ROWS></InsertUpdateRelationalTable></Body></Envelope>"
			api(xml)
		end

		def send_mailing(mailing_id, columns={})
			#{}"<RecipientEmail></RecipientEmail>"
			column_nodes = []
			columns.each do |key, value|
				column_nodes << "<COLUMN><NAME>#{key}</NAME><VALUE>#{value}</VALUE></COLUMN>"
			end
			puts xml = "<Envelope> <Body><SendMailing><MailingId>#{mailing_id}</MailingId><COLUMNS>"+column_nodes.join+"</COLUMNS></SendMailing></Body></Envelope>"
			api(xml)
		end
		
		# def list_recipient_mailings(list_id, recipient_id)
		# 	xml = "<Envelope><Body><ListRecipientMailings><LIST_ID>#{list_id}</LIST_ID><RECIPIENT_ID>33439394</RECIPIENT_ID></ListRecipientMailings></Body></Envelope>"
		# 	api.(xml)
		# end

		private
		def api(xml)
			self.class.post(self.jsession_id_encoded, :body => {:xml => xml})
		end
	end
end