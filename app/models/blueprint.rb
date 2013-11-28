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
  	materials = get_invention_materials
  	datacores = materials.select { |item| item["group"]["name"] == "Datacores" }
  	data_interface = materials.select { |item| item["group"]["name"] == "Data Interfaces" }.first
  	{ "datacores" => datacores, "data_interface" => data_interface }
  end
  
  def raw_materials
  	get_materials.map do |item|
  		recycled = get_recycled_materials.select{ |recycled| recycled["material"]["id"] == item["material"]["id"] }.first
			recycled ? item["recycled_quantity"] = recycled["quantity"] : item["recycled_quantity"] = 0
			
  		item["damage_per_job"] = 1.0		#add this in case the material needs to be displayed as a Component
  		item["wasted_quantity"] = (item["quantity"] * waste["current"]).round
  		item["total_quantity"] = item["quantity"] + item["wasted_quantity"] - item["recycled_quantity"]
  		item
  	end
  end
  
  def components
  	get_requirements.select{ |item| item["activity"]["id"] == 1 and item["category"]["id"] != 16 }.map do |material|
  		material["wasted_quantity"] = 0
  		material
  	end
  end
  
  private
  
  #Methods for accessing Blueprint info on EveData
  def get_details
  	@details ||= evedata.get("/blueprints/#{id}").body.first
  end
  
  def get_requirements
  	@requirements ||= evedata.get("/blueprints/#{id}/requirements").body
  end
  
  def get_materials
  	query = lambda { evedata.get("/items/#{get_details["product"]["id"]}/materials").body }
  	@materials ||= query.call
  end
  
  def get_recycled_details
  	query = lambda do
  		recycled = get_requirements.select{ |item| item["recycle"] == true }.first
  		recycled ? type_id = recycled["material"]["id"] : type_id = 0
  		evedata.get("/blueprints?product_id=#{type_id}").body.first
  	end
  	
  	@recycled_details ||= query.call
  end
  
  def get_recycled_materials
  	query = lambda do
  		blueprint = get_recycled_details
  		blueprint ? product_id = blueprint["product"]["id"] : product_id = 0
  		evedata.get("/items/#{product_id}/materials").body
  	end
  	
  	@recycled_materials ||= query.call
  end
  
  def get_invention_materials
  	query = lambda do
  		blueprint = get_recycled_details
  		blueprint ? blueprint_id = blueprint["id"] : blueprint_id = 0
  		evedata.get("/blueprints/#{blueprint_id}/requirements?activity_id=8").body
  	end
  	
  	@invention_materials ||= query.call
  end
  
  def evedata
  	Faraday.new(:url => "http://evedata.herokuapp.com") do |conn|
  		conn.request :json
  		conn.response :json, :content_type => /\bjson$/
  		conn.adapter Faraday.default_adapter
  	end
  end
end
