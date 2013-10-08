class BlueprintsController < ApplicationController
  def index
  	if params[:like_name]
  		@blueprints = evedata.get("/blueprints?like_name=#{params[:like_name]}").body
  	else
  		@blueprints = evedata.get("/blueprints").body
  	end
  end

  def show
  	@blueprint = evedata.get("/blueprints/#{params[:id]}").body.first
  	@blueprint = evedata.get("/blueprints?product_id=#{params[:id]}").body.first if @blueprint.nil?
  	@product = evedata.get("/items/#{@blueprint['product_id']}").body.first
  	@raw_materials = evedata.get("/items/#{@blueprint['product_id']}/materials").body
  	@extra_materials = evedata.get("/blueprints/#{params[:id]}/requirements?activity_id=1&not_category_id=16").body
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
