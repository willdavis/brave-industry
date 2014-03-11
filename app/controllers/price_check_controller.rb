class PriceCheckController < ApplicationController
	def index
	end
	
  def results
  	@results = Nokogiri::XML params[:input_file]
  	@fitting = @results.xpath("//fitting").first
  	@ship = @results.xpath("//shipType").first
  	
  	@market = params[:market_sort]
  	@region = Region.find(params[:region_id])
  	@solar_name = params[:solar_name]
  	@solar_id = params[:solar_id]
  	
  	ship_data = Rails.cache.fetch("Items.by_name=#{@ship[:value]}") { evedata.get("/items?name=#{@ship[:value]}").body.first }
  	@ship[:id] = ship_data["id"]
  	
  	@hardware = @results.xpath("//hardware")
  	@hardware.map do |item|
  		item_data = Rails.cache.fetch("Items.by_name=#{item[:type]}") { evedata.get("/items?name=#{item[:type]}").body.first }
  		item[:id] = item_data["id"]
  	end
  end
  
  private
  def evedata
  	Faraday.new(:url => "http://evedata.herokuapp.com") do |conn|
  		conn.request :json
  		conn.response :json, :content_type => /\bjson$/
  		conn.adapter Faraday.default_adapter
  	end
  end
end
