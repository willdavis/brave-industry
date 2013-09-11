class BlueprintsController < ApplicationController
  def index
  	@blueprints = evedata.get("/blueprints").body
  end

  def show
  	@blueprint = evedata.get("/blueprints/#{params[:id]}").body.first
  	@raw_materials = []
  	@extra_materials = evedata.get("/blueprints/#{params[:id]}/requirements?activity_id=1&not_category_id=16").body
  	@skills = evedata.get("/blueprints/#{params[:id]}/requirements?activity_id=1&category_id=16").body
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
