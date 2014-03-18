class MarketsController < ApplicationController
	def show
	  @market = Market.find(params[:region_id], params[:type_id])
	end
end
