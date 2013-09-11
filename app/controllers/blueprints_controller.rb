class BlueprintsController < ApplicationController
  def index
  	connection = Faraday.new(:url => "http://evedata.herokuapp.com") do |conn|
  		conn.request :json
  		conn.response :json, :content_type => /\bjson$/
  		conn.adapter Faraday.default_adapter
  	end
  	
  	@blueprints = connection.get("/blueprints").body
  end

  def show
  end
end
