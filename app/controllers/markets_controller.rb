class MarketsController < ApplicationController
  def index
    @market = Market.find("region",10000002,nil)
  end

	def show
	  if params[:type_id].match(/\D+/)
	    params[:type_name] = params[:type_id]
	    params[:type_id] = Item.find_by_name(params[:type_id]).id
	  end
	  
	  if params[:id].match(/\D+/)
	    params[:system_name] = params[:id]
	    params[:id] = SolarSystem.find_by_name(params[:id]).id
	  end
	  
	  @market = Market.find(params[:location], params[:id], params[:type_id])
	  @market.system_name = params[:system_name]
	end
end
