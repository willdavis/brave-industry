class PriceCheckController < ApplicationController
	def index
	end
	
  def results
  	@results = params[:input_file]
  end
end
