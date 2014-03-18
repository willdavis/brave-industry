class BlueprintsController < ApplicationController
  def index
  	if params[:like_name]
  		@blueprints = evedata.get("/blueprints?like_name=#{params[:like_name]}").body
  	else
  		@blueprints = Rails.cache.fetch('Blueprints.all') { evedata.get("/blueprints").body }
  	end
  end
  
  def browse
  	@blueprint_groups = Kaminari.paginate_array(Group.find_by_category_id(9)).page(params[:page]).per(params[:limit])
  end

  def show
		params["material_efficiency"] = params["ME"].to_i
		params["solar_id"] = SolarSystem.find_by_name(params["solar_name"]).id if !params["solar_name"].nil?
		params["region_id"] = 10000002 if params["region_id"].nil?
  	@blueprint = Blueprint.new(params)
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
