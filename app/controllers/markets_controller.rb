class MarketsController < ApplicationController
  def index
    @market = Market.new(:region_id=>10000002)
  end

	def show
	  @market = Market.find(params[:region_id], params[:type_id])
	end
end
