class PriceCheckController < ApplicationController
	def index
	end
	
  def results
  	@results = Nokogiri::XML params[:input_file]
  	@fitting = @results.xpath("//fitting").first
  	@ship = @results.xpath("//shipType").first
  	
  	@location = params[:location]
  	@region = Region.find(params[:region_id])
  	@system_name = params[:system_name]
  	@system_id = SolarSystem.find_by_name(params[:system_name]).id if params[:system_name]
  	
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
