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
  
  def base_waste
  	get_details["waste_factor"]
  end
  
  def production_time
  	get_details["production_time"]
  end
  
  def tech_level
  	get_details["tech_level"]
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
  
  private
  
  #Methods for accessing Blueprint info on EveData
  def get_details
  	evedata.get("/blueprints/#{id}").body.first
  end
  
  def get_requirements
  	evedata.get("/blueprints/#{id}/requirements").body
  end
  
  def get_materials
  	blueprint_product_id = get_details["product"]["id"]
  	evedata.get("/items/#{blueprint_product_id}/materials").body
  end
  
  def evedata
  	Faraday.new(:url => "http://evedata.herokuapp.com") do |conn|
  		conn.request :json
  		conn.response :json, :content_type => /\bjson$/
  		conn.adapter Faraday.default_adapter
  	end
  end
end
