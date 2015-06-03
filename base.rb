class SilverpopConnector < Sinatra::Base
		post '/deliver/cart-abandonment' do
		 	ap(params)
 		 	cart_abandonment = CartAbandonment.new(params)
 		 	ap(cart_abandonment)
			cart_abandonment.deliver!
			#@silverpop.logout
		end

		post '/deliver' do

		end
end

