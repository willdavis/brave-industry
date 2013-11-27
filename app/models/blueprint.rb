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
  	base = get_details["waste_factor"]
  	base_modifier = base * 0.01
  	material_efficiency >= 0 ? current_waste = base_modifier / (1 + material_efficiency) : current_waste = base_modifier * (1 - material_efficiency)
  	{ "base" => base, "current" => current_waste }
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
  	@raw_materials ||= get_materials
  end
  
  def components
  	@components ||= get_requirements.select{ |item| item["activity"]["id"] == 1 and item["category"]["id"] != 16 }
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
  	blueprint_product_id = get_details["product"]["id"]
  	@materials ||= evedata.get("/items/#{blueprint_product_id}/materials").body
  end
  
  def get_recycled_component
  	type_id = get_requirements.select{ |item| item["recycle"] == true }.first["material"]["id"]
  	@recycled_component ||= evedata.get("/blueprints?product_id=#{type_id}").body.first
  end
  
  def get_invention_materials
  	blueprint_id = get_recycled_component["id"]
  	@invention_materials ||= evedata.get("/blueprints/#{blueprint_id}/requirements?activity_id=8").body
  end
  
  def evedata
  	Faraday.new(:url => "http://evedata.herokuapp.com") do |conn|
  		conn.request :json
  		conn.response :json, :content_type => /\bjson$/
  		conn.adapter Faraday.default_adapter
  	end
  end
end
