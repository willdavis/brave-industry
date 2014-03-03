class Blueprint
  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # ActiveModel support
  def persisted?; false; end
  def save!; true; end
  
  # Dynamic attributes should match the values supplied by form_for params
  ATTRIBUTES = [:id, :invented, :material_efficiency]
  attr_accessor *ATTRIBUTES
  
  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end
  
  def name
  	get_details["name"]
  end
  
  def waste
  	base = get_details["waste_factor"] * 0.01
  	material_efficiency >= 0 ? current = base / (1 + material_efficiency) : current = base * (1 - material_efficiency)
  	{ "base" => base, "current" => current }
  end
  
  def production_time
  	get_details["production_time"]
  end
  
  def tech_level
  	get_details["tech_level"]
  end
  
  def images
  	get_details["images"]
  end
  
  def group
  	id = get_details["group"]["id"].to_i
  	name = get_details["group"]["name"]
  	{ "id" => id, "name" => name }
  end
  
  def product
  	id = get_details["product"]["id"]
  	batch_size = get_details["product"]["batch_size"]
  	{ "id" => id, "batch_size" => batch_size.to_i }
  end
  
  def skills
  	requirements = get_requirements
  	manufacturing = requirements.select { |item| item["category"]["id"].to_i == 16 and item["activity"]["id"] == 1 }
  	{ "manufacturing" => manufacturing }
  end
  
  def invention
  	build_invention_materials = lambda do
  		if tech_level == 2
				materials = get_invention_materials
				datacores = materials.select { |item| item["group"]["name"] == "Datacores" }
				data_interface = materials.select { |item| item["group"]["name"] == "Data Interfaces" }.first
				{ "datacores" => datacores, "data_interface" => data_interface }
			else
				{ "datacores" => [], "data_interface" => nil }
			end
  	end
		
		@invention ||= build_invention_materials.call
  end
  
  def materials
  	build_materials = lambda do
      #find raw materials
      raw = get_materials.select{ |item| item["material"]["blueprint_id"].nil? }.map do |item|
	      if tech_level == 2
		      recycled_item = get_recycled_materials.select{ |recycled| recycled["material"]["id"] == item["material"]["id"] }.first
		      recycled_item ? item["recycled_quantity"] = recycled_item["quantity"] : item["recycled_quantity"] = 0
	      else
		      item["recycled_quantity"] = 0
	      end
	
	      item["extra_quantity"] = 0
	      item["wasted_quantity"] = (item["quantity"] * waste["current"]).round
	      item["total_quantity"] = item["quantity"] + item["wasted_quantity"] - item["recycled_quantity"]
	      item
      end

			#find any components that are actually raw materials
      extra = get_requirements.select{ |item| item["activity"]["id"] == 1 and item["category"]["id"].to_i != 16 and item["material"]["blueprint_id"].nil? }.map do |item|
        item["extra_quantity"] = 0
	      item["wasted_quantity"] = 0
	      item["recycled_quantity"] = 0
	      item["total_quantity"] = item["quantity"]
	      item
      end

      #merge any extra raw materials into the main array
      extra.each do |extra_item|
        item = raw.select{ |raw_item| raw_item["material"]["id"] == extra_item["material"]["id"] }.first
        item["extra_quantity"] = extra_item["quantity"] if !item.nil?
        item["total_quantity"] += extra_item["quantity"] if !item.nil?
        raw.push(extra_item) if item.nil?
      end

      return raw.select{ |item| item["total_quantity"] > 0 }
  	end

  	@materials ||= build_materials.call
  end
  
  def components
  	build_components = lambda do
			#find all components
  		components = get_requirements.select{ |item| item["activity"]["id"] == 1 and item["category"]["id"].to_i != 16 and !item["material"]["blueprint_id"].nil? }.map do |item|
				item["wasted_quantity"] = 0
				item["material"]["blueprint_id"] = item["material"]["blueprint_id"].to_i  #patch fix
				item["total_quantity"] = item["quantity"] + item["wasted_quantity"]
				item
			end

			#check for any materials with a blueprint_id
			materials = get_materials.select{ |item| !item["material"]["blueprint_id"].nil? }.map do |item|
				item["damage_per_job"] = 1.0
				item["wasted_quantity"] = 0
				item["material"]["blueprint_id"] = item["material"]["blueprint_id"].to_i  #patch fix
				item["total_quantity"] = item["quantity"]
				item
			end

			#merge any component materials to the component array
			materials.each do |item|
				components.push(item)
			end

			return components
  	end
  	
  	@components ||= build_components.call
  end
  
  def has_components?
  	!components.empty?
  end
  
  def has_materials?
  	!materials.empty?
  end
  
  def has_invention_materials?
  	!invention["datacores"].empty? and !invention["data_interface"].nil?
  end
  
  private
  
  #Methods for accessing Blueprint info on EveData
  def get_details
  	@details ||= Rails.cache.fetch("blueprint.#{id}.details") { evedata.get("/blueprints/#{id}").body.first }
  end
  
  def get_requirements
  	@requirements ||= Rails.cache.fetch("blueprint.#{id}.requirements") { evedata.get("/blueprints/#{id}/requirements").body }
  end
  
  def get_materials
  	query = lambda { evedata.get("/items/#{get_details["product"]["id"]}/materials").body }
  	@raw_materials ||= Rails.cache.fetch("blueprint.#{id}.materials") { query.call }
  end
  
  def get_recycled_details
  	query = lambda do
  		recycled = get_requirements.select{ |item| item["recycle"] == true }.first
  		recycled ? type_id = recycled["material"]["id"] : type_id = 0
  		evedata.get("/blueprints?product_id=#{type_id}").body.first
  	end
  	
  	@recycled_details ||= Rails.cache.fetch("blueprint.#{id}.recycled_details") { query.call }
  end
  
  def get_recycled_materials
  	query = lambda do
  		blueprint = get_recycled_details
  		blueprint ? product_id = blueprint["product"]["id"] : product_id = 0
  		evedata.get("/items/#{product_id}/materials").body
  	end
  	
  	@recycled_materials ||= Rails.cache.fetch("blueprint.#{id}.recycled_materials") { query.call }
  end
  
  def get_invention_materials
  	query = lambda do
  		blueprint = get_recycled_details
  		blueprint ? blueprint_id = blueprint["id"] : blueprint_id = 0
  		evedata.get("/blueprints/#{blueprint_id}/requirements?activity_id=8").body
  	end
  	
  	@raw_invention_materials ||= Rails.cache.fetch("blueprint.#{id}.invention_materials") { query.call }
  end
  
  def evedata
  	Faraday.new(:url => "http://evedata.herokuapp.com") do |conn|
  		conn.request :json
  		conn.response :json, :content_type => /\bjson$/
  		conn.adapter Faraday.default_adapter
  	end
  end
end
