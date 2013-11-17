class BlueprintsController < ApplicationController
  def index
  	if params[:like_name]
  		@blueprints = evedata.get("/blueprints?like_name=#{params[:like_name]}").body
  	else
  		@blueprints = Rails.cache.fetch('Blueprints.all') { evedata.get("/blueprints").body }
  	end
  end
  
  def browse
  	@blueprint_groups = Rails.cache.fetch('Blueprints.Groups.all') { evedata.get("/categories/9/groups?limit=150").body }
  end

  def show
  	@blueprint = Rails.cache.fetch("Blueprints.#{params[:id]}") {
  	
  		#Lookup the essential blueprint data and required materials
  		blueprint = evedata.get("/blueprints/#{params[:id]}").body.first
  		blueprint["requirements"] = evedata.get("/blueprints/#{params[:id]}/requirements").body
  		blueprint["raw_materials"] = evedata.get("/items/#{blueprint['product']['id']}/materials").body
  		blueprint["extra_materials"] = blueprint["requirements"].select do |item|
  			item["activity"]["id"] == 1 and item["category"]["id"] != 16
  		end
  		blueprint["skills"] = blueprint["requirements"].select do |item|
  			item["activity"]["id"] == 1 and item["category"]["id"].to_i == 16
  		end
  		
  		#Setup basic invention variables.  These will only be relavent for Tech2 blueprints
			blueprint["invention"] = {}
			blueprint["invention"]["datacores"] = []
			blueprint["invention"]["data_interface"] = nil
			
			#Check if there is a recycled component
			#If so, lookup it's raw materials and store them
  		blueprint["recycled_components"] = blueprint["extra_materials"].select { |material| material["recycle"] == true }
			blueprint["recycled_materials"] = []
			blueprint["recycled_components"].each do |component|
				component_id = component['material']['id']
				component_blueprint_id = evedata.get("/blueprints?product_id=#{component_id}").body.first["id"]
				invention_components = evedata.get("/blueprints/#{component_blueprint_id}/requirements?activity_id=8").body
				
				#Only Tech2 blueprints have recycled components.
				#Therefore, it also has invention components.
				blueprint["invention"]["datacores"] = invention_components.select{ |item| item["group"]["name"] == "Datacores" }
				blueprint["invention"]["data_interface"] = invention_components.select{ |item| item["group"]["name"] == "Data Interfaces" }.first
				
				blueprint["recycled_materials"].concat(evedata.get("/items/#{component_id}/materials").body)
			end
			
			#Recycling!!!
			#Subtract all recycled materials from the blueprints raw materials
			#Remove the raw material if it's less than or equal to zero
			blueprint["recycled_materials"].each do |recycled|
				blueprint["raw_materials"].map do |raw|
					if raw['material']['id'] == recycled['material']['id']
						raw['quantity'] -= recycled['quantity']
						blueprint["raw_materials"].delete(raw) if raw['quantity'] <= 0
					end
				end
			end
  		
  		blueprint
  	}
  	
  	@material_efficiency = params[:ME].nil? ? 0 : params[:ME].to_i
  	@invented = params[:invented]
  	
  	#Calculate waste for raw materials
  	#Materials Needed = Base Materials + (Base Waste)/(1 + ME)
  	base_waste = @blueprint["waste_factor"] * 0.01
  	if @material_efficiency >= 0
  		@waste_factor = base_waste / (1 + @material_efficiency)
  	else
  		@waste_factor = base_waste * (1 - @material_efficiency)
  	end
  	
  	#Apply waste to raw materials
  	@blueprint["raw_materials"].map do |material|
  		material["damage_per_job"] = 1.0		#add this in case the material is a Component
  		material["wasted_materials"] = (material["quantity"] * @waste_factor).round
  		material["quantity"] += material["wasted_materials"]
  	end
  	
  	#waste does not apply to extra materials but some might be base materials
		@blueprint["extra_materials"].map { |material| material["wasted_materials"] = 0 }
		
		#Some blueprints have duplicate materials in the raw and extra tables
		#Find these duplicates and merge them into the raw materials array
		#NOTE!!!  This MUST BE DONE AFTER calculating raw material waste!!!
		@blueprint["raw_materials"].each do |raw_mat|
			intersection = @blueprint["extra_materials"].select { |extra_mat| extra_mat['material']['id'] == raw_mat['material']['id'] }
			intersection.each do |material|
				raw_mat['quantity'] += material['quantity']
				@blueprint["extra_materials"].delete(material)
			end
		end
  	
  	#Merge raw and extra materials
  	all_materials = @blueprint["raw_materials"].concat(@blueprint["extra_materials"])
  	
  	#Select components based on Category IDs
  	@component_materials = all_materials.select { |m| ["17","6","23","7","18"].include?(m['category']['id']) }
  	@raw_materials = all_materials.select { |m| ["4","43","25"].include?(m['category']['id']) }
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
