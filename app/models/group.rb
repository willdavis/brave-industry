class Group
  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # ActiveModel support
  def persisted?; false; end
  def save!; true; end
  
  # Dynamic attributes should match the values supplied by form_for params
  ATTRIBUTES = [:id, :name]
  attr_accessor *ATTRIBUTES
  
  def initialize(attributes = {})
    ATTRIBUTES.each do |attribute|
      send("#{attribute}=", attributes[attribute])
    end
  end
  
  def members; get_members; end
  
  private
  
  def get_members
    query = lambda do
      members = Rails.cache.fetch("group.#{id}.members") { evedata.get("/blueprints?group_id=#{id}&limit=200").body }
      members.map{ |member| Blueprint.new(:id=>member["id"]) }
    end
    
    @members ||= query.call
  end
  
  def evedata
  	@connection ||= Faraday.new(:url => "http://evedata.herokuapp.com") do |conn|
  		conn.request :json
  		conn.response :json, :content_type => /\bjson$/
  		conn.adapter Faraday.default_adapter
  	end
  end
end
