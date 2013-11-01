require 'spec_helper'

describe PriceCheckController do
	
	describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end
	
  describe "POST 'results'" do
    it "returns http success" do
      get 'results'
      response.should be_success
    end
  end

end
