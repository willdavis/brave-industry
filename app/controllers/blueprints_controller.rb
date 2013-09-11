class BlueprintsController < ApplicationController
  def index
  	@blueprints = evedata.get("/blueprints").body
  end

  def show
  	@blueprint = evedata.get("/blueprints/#{params[:id]}").body.first
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
