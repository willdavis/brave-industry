class Market
  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # ActiveModel support
  def persisted?; false; end
  def save!; true; end
  
  # ActiveRecord queries
  def self.find(region_id, type_id); Market.get_market(region_id, type_id); end
  
  # Dynamic attributes should match the values supplied by form_for params
  ATTRIBUTES = [:region_id, :solar_id, :solar_name, :type_name, :type_id, :raw_data, :market_in, :location]
  attr_accessor *ATTRIBUTES
  
  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end
  
  def region
    @region ||= Region.new(:id=>region_id)
  end
  
  def solar_system
    @solar_system ||= SolarSystem.find_by_id(solar_id)
  end
  
  def item
    @item ||= Item.new(:id=>type_id, :name=>type_name)
  end
  
  def raw_data
    @raw_data ||= Rails.cache.fetch("market.#{region_id}.#{type_id}", expires_in: 1.days, compress: true) { Market.evedata.get("/market/#{region_id}/types/#{type_id}/history/").body }
  end
  
  private
  
  def self.get_market(r_id, t_id)
    data = []#Rails.cache.fetch("market.#{r_id}.#{t_id}", expires_in: 1.days, compress: true) { Market.evedata.get("/market/#{r_id}/types/#{t_id}/history/").body }
    return Market.new(:region_id => r_id, :type_id => t_id, :raw_data => data) if !data.nil?
    return Market.new if data.nil?
  end
  
  def self.evedata
    @connection ||= Faraday.new(:url => "http://public-crest.eveonline.com") do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
    end
  end
end
