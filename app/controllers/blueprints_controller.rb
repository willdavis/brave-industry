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
