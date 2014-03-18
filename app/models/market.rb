class Market
  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # ActiveModel support
  def persisted?; false; end
  def save!; true; end
  
  # ActiveRecord queries
  def self.find(region_id, product_id); Market.get_market(region_id, product_id); end
  
  # Dynamic attributes should match the values supplied by form_for params
  ATTRIBUTES = [:region_id, :product_id, :raw_data]
  attr_accessor *ATTRIBUTES
  
  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end
  
  def raw_data
    @raw_data ||= Rails.cache.fetch("market.#{region_id}.#{product_id}") { Market.evedata.get("/market/#{region_id}/types/#{product_id}/history/").body }
  end
  
  private
  
  def self.get_market(r_id, p_id)
    data = Rails.cache.fetch("market.#{r_id}.#{p_id}") { Market.evedata.get("/market/#{r_id}/types/#{p_id}/history/").body }
    return Market.new(:region_id => r_id, :product_id => p_id, :raw_data => data) if !data.nil?
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
