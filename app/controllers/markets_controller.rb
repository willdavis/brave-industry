class MarketsController < ApplicationController
  def index
  end

	def show
	  @market = Market.find(params[:region_id], params[:type_id])
	end
end
