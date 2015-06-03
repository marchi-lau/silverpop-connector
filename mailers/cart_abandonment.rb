class CartAbandonment
		attr_accessor :jsession_id,
					  :abandonment_id, 
					  :registration_id, 
					  :origin, 
					  :destination, 
					  :cabin,
					  :trip_type,
					  :date_departure, 
					  :date_return, 
					  :pax_adult, 
					  :pax_child, 
					  :pax_infant, 
					  :segmented_cabins, 
					  :segmented_airports,
					  :segmented_dates_departure,
					  :country,
					  :language,
					  :db_cart_abandoners,
					  :rt_itinerary,
					  :rt_segments,
					  :rt_destination_guide,
					  :ml_cart_abandonment,
					  :abandoned_at, 
					  :searched_at,
					  :silverpop
		
		def initialize(params={}) # Retrieve Tealium AudienceStream parameters
 		     @abandonment_id = UUIDTools::UUID.timestamp_create.to_s #For linking up between relational tables
		    @registration_id = params[:registration_id]
		   		@jsession_id = params[:jsession_id]
		  	 		 @origin = Airport.new(params[:origin])
		 	    @destination = Airport.new(params[:destination])
			 @date_departure = params[:date_departure]
			 	@date_return = params[:date_return]
				  @pax_adult = params[:pax_adult].to_i
				  @pax_child = params[:pax_child].to_i
				 @pax_infant = params[:pax_infant].to_i
					  @cabin = Cabin.new(params[:cabin])
				  @trip_type = params[:trip_type]
		   @segmented_cabins = params[:segmented_cabins].split('|')  # Dummy
		 @segmented_airports = params[:segmented_airports].split('|') #Dummy
  @segmented_dates_departure = params[:segmented_dates_departure].split('|')  #Dummy
			   	   @language = params[:language]
			        @country = params[:country]
		 @db_cart_abandoners = params[:db_cart_abandoners]#'3643168'  # Mailing DB
		        @rt_segments = params[:rt_segments]#'3644072'  # Relational Table ID of Cart Abandonment - Segments
			   @rt_itinerary = params[:rt_itinerary]#'3643931'  # Relational Table ID of Cart Abandonment - Itinerary
	   @rt_destination_guide = params[:rt_destination_guide]#'3644195'  # Relational Table iD of Cart Abandonment - Destination Guide
	    @ml_cart_abandonment = params[:ml_cart_abandonment]#'22745825' # MailingID of Autoresponder Mailing. (Not the original MailingID's)
	   		   @abandoned_at = ''
	   		   @silverpop 	 = Silverpop::Client.new({username: 'silverpop.api@cathaypacific.com', password: 'Qqwe123#', endpoint: 'http://api3.silverpop.com/XMLAPI'})
		end

		def add_recipient 
			  email = 'ecxgal@gmail.com'
		family_name = "Leung"
		 given_name = "Garble"
			puts silverpop.add_recipient(db_cart_abandoners, {:"Email" => email,  :MEMB_NUM => registration_id, :"FAMILY NAME" => family_name, :"GIVEN NAME" => given_name})								 
		end

		def update_recipient
			puts silverpop.update_recipient(db_cart_abandoners, {:"MEMB_NUM" => registration_id, :abandonment_id => abandonment_id, :jsession_id => jsession_id})
		end
		
		def update_itinerary
	  		puts silverpop.insert_update_relational_table(rt_itinerary, {abandonment_id: abandonment_id,
																 jsession_id: jsession_id,
																 registration_id: registration_id, 
																 origin: origin.code, 
																 destination: destination.code,
																 date_departure: date_departure,
																 date_return: date_return,
																 cabin: cabin.code,
																 trip_type: trip_type,
																 pax_adult: pax_adult,
																 pax_child: pax_child,
																 pax_infant: pax_infant,
																 country: country,
																 language: language,
																 book_url: '', #DeepLink.new()
																 abandoned_at: '',
																 searched_at: ''})
		end

		def update_segments
			segmented_airports.each_with_index do |airport, index|
			  	origin = Airport.new(airport.split('_')[0])
			  	destination = Airport.new(airport.split('_')[1])
			  	cabin_name = Cabin.new(segmented_cabins[index])
			  	date_departure = segmented_dates_departure[index]

			  	puts silverpop.insert_update_relational_table(rt_segments, {abandonment_id: abandonment_id,
			  														   jsession_id: jsession_id,
			  														   registration_id: registration_id, 
			  														   date_departure: date_departure, 
			  														   origin_name: origin.name, 
			  														   destination_name: destination.name, 
			  														   cabin_name: cabin.name,
			  														   abandoned_at:  '',
			  														   searched_at: ''})
			end
		end
		
		def update_destination_guide
			destination_guide = DestinationGuide.new(destination.name, language, country)
			puts silverpop.insert_update_relational_table(rt_destination_guide, {abandonment_id: abandonment_id,											  	
																			jsession_id: jsession_id,
																			destination_name: destination.name,
																	  		left_intro: destination_guide.attractions[0].intro,
																			left_image: destination_guide.attractions[0].image_url,
																			left_title: destination_guide.attractions[0].title,
																			left_category: destination_guide.attractions[0].category,
																			right_intro: destination_guide.attractions[1].intro,
																			right_image: destination_guide.attractions[1].image_url,
																			right_title: destination_guide.attractions[1].title,
																			right_category: destination_guide.attractions[1].category,
																			see_more_url: destination_guide.url,
																			abandoned_at: '',
																			searched_at: ''})
		end

		def deliver!
			add_recipient # Add recipient to "Cart Abandoners" // Development only
			update_recipient # Update recipient with UUID abandonment event 		
			update_itinerary # Add to Relational Table - "Cart Abandonment - Itinerary"
			update_segments # Add to Relational Table - "Cart Abandonment - Segments"
			update_destination_guide # Add to Relational Table - "Cart Abandonemnt - Destination Guide"
			silverpop.send_mailing(ml_cart_abandonment, {MEMB_NUM: registration_id})# Trigger Autoresponder - Send Cart Abandonment Email
		end
end