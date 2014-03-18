class Region
  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # ActiveModel support
  def persisted?; false; end
  def save!; true; end
  
  # ActiveRecord queries
  def self.all; Region.get_all_regions; end
  def self.find(region_id); Region.get_region(region_id); end
  
  # Dynamic attributes should match the values supplied by form_for params
  ATTRIBUTES = [:id, :name]
  attr_accessor *ATTRIBUTES
  
  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end
  
  def name
    query = lambda do
      data = Rails.cache.fetch("region.#{id}") { Region.evedata.get("/regions/#{id}").body.first }
      data["name"]
    end
    
    @name ||= query.call
  end
  
  private
  
  def self.get_all_regions
    regions = Rails.cache.fetch("regions.all") { Region.evedata.get("/regions?limit=67").body }
    regions.map{ |region| Region.new(:id=>region["id"], :name=>region["name"]) }
  end
  
  def self.get_region(region_id)
    region = Rails.cache.fetch("region.#{region_id}") { Region.evedata.get("/regions/#{region_id}").body.first }
    return Region.new(:id => region["id"], :name => region["name"]) if !region.nil?
    return Region.new if region.nil?
  end
  
  def self.evedata
    @connection ||= Faraday.new(:url => "http://evedata.herokuapp.com") do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
    end
  end
  
end
