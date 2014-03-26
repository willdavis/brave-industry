class Market
  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # ActiveModel support
  def persisted?; false; end
  def save!; true; end
  
  # ActiveRecord queries
  def self.find(location_type, id, item_id); Market.get_market(location_type, id, item_id); end
  
  # Dynamic attributes should match the values supplied by form_for params
  ATTRIBUTES = [:region_id, :system_id, :system_name, :type_name, :type_id, :location]
  attr_accessor *ATTRIBUTES
  
  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end
  
  def region
    @region ||= Region.find(region_id)
  end
  
  def solar_system
    @solar_system ||= SolarSystem.find_by_id(system_id)
  end
  
  def item
    query = lambda do
      return Item.find(type_id) if !type_id.nil?
      return Item.find_by_name(type_name) if type_id.nil? and !type_name.nil?
      return Item.new if type_id.nil? and type_name.nil?
    end
    
    @item ||= query.call
  end
  
  private
  
  def self.get_market(location_type, id, item_id)
    return Market.new(:location => "region", :region_id => id, :type_id => item_id) if location_type == "region"
    return Market.new(:location => "system", :system_id => id, :type_id => item_id) if location_type == "system"
  end
  
  def self.evedata
    @connection ||= Faraday.new(:url => "http://public-crest.eveonline.com") do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
    end
  end
end
