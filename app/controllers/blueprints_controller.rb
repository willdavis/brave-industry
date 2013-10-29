class BlueprintsController < ApplicationController
  def index
  	if params[:like_name]
  		@blueprints = evedata.get("/blueprints?like_name=#{params[:like_name]}").body
  	else
  		@blueprints = Rails.cache.fetch('Blueprints.all') { evedata.get("/blueprints").body }
  	end
  end

  def show
  	#Get blueprint and item data
  	@blueprint = Rails.cache.fetch("Blueprint.#{params[:id]}") { evedata.get("/blueprints/#{params[:id]}").body.first }
  	@product = evedata.get("/items/#{@blueprint['product_id']}").body.first
  	
  	#Get both raw and extra materials
  	raw = Rails.cache.fetch("Blueprint.#{params[:id]}.raw_materials") { evedata.get("/items/#{@blueprint['product_id']}/materials").body }
  	extra = Rails.cache.fetch("Blueprint.#{params[:id]}.extra_materials") { evedata.get("/blueprints/#{params[:id]}/requirements?activity_id=1&not_category_id=16").body }
  	
  	#Lookup the params and save them for later
  	@material_efficiency = params[:ME].nil? ? 0 : params[:ME].to_i
  	@component_type_ids = params[:include_components]
  	
  	#Check if an extra materials needs to be recycled
  	#If so, look up it's raw materials
  	@recycled_components = extra.select { |material| material["recycle"] == true }
  	@recycled_raw_materials = @recycled_components.map do |component|
  		evedata.get("/items/#{component['material']['id']}/materials").body
  	end
  	
  	#Subtract each recycled raw material from the blueprints raw materials
  	#If the new total is <= zero, delete the material from the list
  	if !@recycled_raw_materials.empty?
			@recycled_raw_materials.first.each do |material|
				raw.map do |raw_material|
					if raw_material['material']['id'] == material['material']['id']
						raw_material['quantity'] -= material['quantity']
						raw.delete(raw_material) if raw_material['quantity'] <= 0
					end
				end
			end
		end
  	
  	#Calculate waste for raw materials
  	#Materials Needed = Base Materials + (Base Waste)/(1 + ME)
  	base_waste = @blueprint["waste_factor"] * 0.01
  	if @material_efficiency >= 0
  		@waste_factor = base_waste / (1 + @material_efficiency)
  	else
  		@waste_factor = base_waste * (1 - @material_efficiency)
  	end
  	
  	#Apply waste to raw materials
  	raw.map do |material|
  		material["damage_per_job"] = 1.0		#add this in case the material is a Component
  		material["wasted_materials"] = (material["quantity"] * @waste_factor).round
  		material["quantity"] += material["wasted_materials"]
  	end
  	
  	#waste does not apply to extra materials
  	#but some might need to be displayed as a raw material
  	extra.map { |material| material["wasted_materials"] = 0 }
  	
  	#find any duplicate materials in the extra table and add their quantities to the raw material's
  	#delete the extra table entry afterwards
  	raw.each do |raw_mat|
  		intersection = extra.select { |extra_mat| extra_mat['material']['id'] == raw_mat['material']['id'] }
  		intersection.each do |material|
  			raw_mat['quantity'] += material['quantity']
  			extra.delete(material)
  		end
  	end
  	
  	#Merge raw and extra materials
  	all_materials = raw.concat(extra)
  	
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
