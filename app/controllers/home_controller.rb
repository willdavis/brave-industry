class HomeController < ApplicationController
  def index
  	@blueprint_groups = Rails.cache.fetch('BlueprintGroups.all') { evedata.get("/categories/9/groups?limit=150").body }
  end
  
  def health_check
  	render :nothing => true, :status => 200
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
