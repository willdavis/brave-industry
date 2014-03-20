class Item
  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # ActiveModel support
  def persisted?; false; end
  def save!; true; end
  
  # ActiveRecord support
  def self.all; Item.get_all; end
  def self.find(item_id); Item.get_item(item_id); end
  def self.find_by_name(name); Item.get_item_by_name(name); end
  
  # Dynamic attributes should match the values supplied by form_for params
  ATTRIBUTES = [:id, :name, :images]
  attr_accessor *ATTRIBUTES
  
  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end
  
  def name  
    @name ||= get_details["name"]
  end
  
  def images
    @images ||= get_details["images"]
  end
  
  private
  
  def get_details
    Rails.cache.fetch("item.#{id}") { Item.evedata.get("/items/#{id}").body.first }
  end
  
  def self.get_all
    items = Rails.cache.fetch("item.all.names", compress: true) do
      Item.evedata.get("/items?limit=1000000").body.map{ |item| item["name"] }
    end
    
    items.map{ |name| Item.new(:name=>name) }
  end
  
  def self.get_item_by_name(item_name)
    data = Rails.cache.fetch("item.#{item_name}") { Item.evedata.get("/items?name=#{item_name}").body.first }
    return Item.new(:id => data["id"], :name => data["name"], :images => data["images"]) if !data.nil?
    return Item.new if data.nil?
  end
  
  def self.get_item(item_id)
    data = Rails.cache.fetch("item.#{item_id}") { Item.evedata.get("/items/#{item_id}").body.first }
    return Item.new(:id => data["id"], :name => data["name"], :images => data["images"]) if !data.nil?
    return Item.new if data.nil?
  end
  
  def self.evedata
  	@connection ||= Faraday.new(:url => "http://evedata.herokuapp.com") do |conn|
  		conn.request :json
  		conn.response :json, :content_type => /\bjson$/
  		conn.adapter Faraday.default_adapter
  	end
  end
end
