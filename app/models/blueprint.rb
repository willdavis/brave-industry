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
  
  def product
  	blueprint = get_details
  	{ "id" => blueprint["product"]["id"], "batch_size" => blueprint["product"]["batch_size"].to_i }
  end
  
  #Methods for accessing Blueprint info on EveData
  def get_details
  	evedata.get("/blueprints/#{id}").body.first
  end
  
  def get_requirements
  	evedata.get("/blueprints/#{id}/requirements").body
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
