class Region
  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # ActiveModel support
  def persisted?; false; end
  def save!; true; end
  
  # ActiveRecord queries
  def self.all; get_all_regions; end
  
  # Dynamic attributes should match the values supplied by form_for params
  ATTRIBUTES = [:id]
  attr_accessor *ATTRIBUTES
  
  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end
  
  private
  
  def get_all_regions
    @regions ||= Rails.cache.fetch("regions.all") { evedata.get("/regions?limit=67").body }
  end
  
  def get_region
    @region ||= Rails.cache.fetch("region.#{id}") { evedata.get("/regions/#{id}").body.first }
  end
  
  def evedata
    Faraday.new(:url => "http://evedata.herokuapp.com") do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
    end
  end
  
end
