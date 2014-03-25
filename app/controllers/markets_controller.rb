class MarketsController < ApplicationController
  def index
    @market = Market.new(:region_id=>10000002)
  end

	def show
	  if params[:type_id].match(/\D+/)
	    params[:type_name] = params[:type_id]
	    params[:type_id] = Item.get_item_by_name(params[:type_id]).id
	  end
	  
	  @market = Market.find(params[:location_id], params[:type_id])
	end
end
