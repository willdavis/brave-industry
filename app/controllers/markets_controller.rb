class MarketsController < ApplicationController
	def show
	  @market = Market.find(params[:region_id], params[:product_id])
	end
end
