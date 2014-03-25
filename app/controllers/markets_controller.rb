class MarketsController < ApplicationController
  def index
    @market = Market.find("region",10000002,nil)
  end

	def show
	  if params[:type_id].match(/\D+/)
	    params[:type_name] = params[:type_id]
	    params[:type_id] = Item.get_item_by_name(params[:type_id]).id
	  end
	  
	  @market = Market.find(params[:location], params[:id], params[:type_id])
	end
end
