class BlueprintsController < ApplicationController
  def index
  	if params[:id]
  		@blueprints = evedata.get("/blueprints/#{params[:id]}").body
  	else
  		@blueprints = evedata.get("/blueprints").body
  	end
  end

  def show
  	result = evedata.get("/blueprints/#{params[:id]}").body.first
  	@blueprint = result
  	@raw_materials = evedata.get("/items/#{result['product_id']}/materials").body
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
