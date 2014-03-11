class SolarSystem
  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # ActiveModel support
  def persisted?; false; end
  def save!; true; end
  
  # ActiveRecord queries
  def self.all; SolarSystem.get_all_systems; end
  def self.find_by_id(solar_id); SolarSystem.get_system_by_id(solar_id); end
  def self.find_by_name(solar_name); SolarSystem.get_system_by_name(solar_name); end
  
  # Dynamic attributes should match the values supplied by form_for params
  ATTRIBUTES = [:id, :name]
  attr_accessor *ATTRIBUTES
  
  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end
  
  private
  
  def self.get_all_systems
    systems = Rails.cache.fetch("solar_systems.all", compress: true) { SolarSystem.evedata.get("/solar_systems?limit=5500").body }
    systems.map{ |system| SolarSystem.new(:id=>system["id"], :name=>system["name"]) }
  end
  
  def self.get_system_by_id(solar_id)
    system = Rails.cache.fetch("solar_system.#{solar_id}") { SolarSystem.evedata.get("/solar_systems/#{solar_id}").body.first }
    return SolarSystem.new(:id => system["id"], :name => system["name"]) if !system.nil?
    return SolarSystem.new if system.nil?
  end
  
  def self.get_system_by_name(solar_name)
    system = Rails.cache.fetch("solar_system.#{solar_name}") { SolarSystem.evedata.get("/solar_systems?name=#{solar_name}").body.first }
    return SolarSystem.new(:id => system["id"], :name => system["name"]) if !system.nil?
    return SolarSystem.new if system.nil?
  end
  
  def self.evedata
    @connection ||= Faraday.new(:url => "http://evedata.herokuapp.com") do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
    end
  end
  
end
