class BlueprintsController < ApplicationController
  def index
  	if params[:like_name]
  		@blueprints = evedata.get("/blueprints?like_name=#{params[:like_name]}").body
  	else
  		@blueprints = evedata.get("/blueprints").body
  	end
  end

  def show
  	#Get blueprint and item data
  	@blueprint = evedata.get("/blueprints/#{params[:id]}").body.first
  	@product = evedata.get("/items/#{@blueprint['product_id']}").body.first
  	
  	#Get both raw and extra materials
  	raw = evedata.get("/items/#{@blueprint['product_id']}/materials").body
  	extra = evedata.get("/blueprints/#{params[:id]}/requirements?activity_id=1&not_category_id=16").body
  	
  	#Calculate waste for raw materials
  	#Materials Needed = Base Materials + (Base Waste)/(1 + ME)
  	@waste_factor = @blueprint["waste_factor"]
  	@material_efficiency = 0
  	
  	#Apply waste to raw materials
  	raw.map do |material|
  		material["damage_per_job"] = 1.0		#add this in case the material is a Component
  		if @material_efficiency >= 0
  			material["wasted_materials"] = (material["quantity"] * @waste_factor * 0.01 / (1 + @material_efficiency)).round
  		else
  			material["wasted_materials"] = (material["quantity"] * @waste_factor * 0.01 * (1 - @material_efficiency)).round
  		end
  		material["quantity"] += material["wasted_materials"]
  	end
  	
  	#Merge raw and extra materials
  	#Merge any duplicate materials
  	all_materials = raw.concat(extra)
  	
  	@extra_materials = all_materials.select { |m| ["17","6","23"].include?(m['category']['id']) }
  	@raw_materials = all_materials.select { |m| ["4","43"].include?(m['category']['id']) }
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
